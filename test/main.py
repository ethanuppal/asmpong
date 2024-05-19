import toml, sys, subprocess

with open('./test.toml', 'r') as test_config_file:
    test_config = toml.load(test_config_file)
    dir = test_config['dir']
    loc = test_config['loc']
    init = test_config['init']
    subprocess.run(f'cd {dir} && ' + init, shell=True, capture_output=True)
    did_fail = False
    for test in test_config['test']:
        output_path = test['output']
        command = test['command']
        with open(loc + '/'+ output_path, 'r') as output_file:
            expected = output_file.read()
            process = subprocess.run(f'cd {dir} && ' + command, shell=True, capture_output=True)
            actual = process.stdout.decode('ascii')
            print(f'    \x1b[33mASSERT $(cat {loc}/{output_path}) == $({command})\x1b[m')
            if expected != actual:
                did_fail = True
                print('    \x1b[31mFAIL\x1b[m')
                print(f'    \x1b[2mEXP:\x1b[m {expected}', end='')
                print(f'    \x1b[2mACT:\x1b[m {actual}', end='')
            else:
                print('    \x1b[32mPASS\x1b[m')
    if did_fail:
        sys.exit(1)
