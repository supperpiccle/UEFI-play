import os
import gdb
from string import printable

def read_until(pipe, substring):
    lines = b''
    while True:
        l = pipe.read()
        if l:
            lines += l
            #line = ''.join(filter(lambda x: x > chr(32), line))# (c < chr(32)):
            if substring in lines:
                break
    return lines

def emtpy_pipe(pipe):
    while True:
        c = pipe.read(1)
        if len(c) == 0:
            return

def read_and_print(pipe):
    old_blocking = os.get_blocking(pipe.fileno())
    os.set_blocking(pipe.fileno(), True)
    while True:
        c = pipe.read(1).decode('ascii')
        if c in printable:
            print(c, end='')

def read_line(pipe):
    os.set_blocking(pipe.fileno(), True)
    line = pipe.readline().decode('ascii')
    print(line)
    return line

INPUT_PIPE = '/tmp/guest.in'
OUTPUT_PIPE = '/tmp/guest.out'
SHELL_STR = b'Shell>'
FS0_STR = b'FS0:\\>'
ADD_SYMBOL_FILE_STR = b'add-symbol-file'

print("Connecting to qemu...")
if gdb.selected_inferior().connection:
    gdb.execute('disconnect')

gdb.execute('target remote localhost:1234')
print("gdb connected")
gdb.execute('c&')
print("gdb done")

# Launch qemu
#qemu_process = subprocess.Popen(['sh', './test.sh'])

try:
    # gdb connect
    input_handle = open(INPUT_PIPE, 'wb', 0)
    output_handle = open(OUTPUT_PIPE, 'rb')

    os.set_blocking(output_handle.fileno(), False)

    # Read initial output until "shell>"
    read_until(output_handle, SHELL_STR)
    print("UEFI shell started")

    # Switch to fs0.
    input_handle.write(b"fs0:\r\n")
    read_until(output_handle, FS0_STR)
    print("switched to fs0")

    # run debug application.
    input_handle.write(b'setdbg.efi\r\n')
    read_until(output_handle, FS0_STR)
    print("set_dbg.efi executed")

    # Finally start the shim
    input_handle.write(b'shimx64.efi\r\n')
    read_until(output_handle, ADD_SYMBOL_FILE_STR)
    print("Got line from shimx64.efi executed")

    # Grab the line, but ignore the file, we know it.
    uefi_output = ' '.join(read_line(output_handle).split(' ')[2:])

    gdb_line = f'add-symbol-file /home/jlewis/shim/shimx64.efi.debug {uefi_output}'
    print(f'would use {gdb_line}')
    gdb.execute('interrupt')
    gdb.execute(gdb_line)

except Exception as e:
    print(f"Exception!! {e}")
    pass
finally:
    pass
    #qemu_process.kill()