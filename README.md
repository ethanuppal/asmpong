# asmpong

I'd never made a game in "pure" x86 assembly, so I decided I wanted to.
It's built for a 30x80 terminal.

**Allowed C/POSIX library functions**

- `putchar`
- `fcntl`
- `tcgetattr`
- `tcsetattr`
- `malloc`
- `free`
- `poll`
- `read`

This list will diminish over time as I reduce dependencies on the C/POSIX.

**There's PYTHON! What's that about?**

I used python to write the [launch file](./launch) and [test driver](./test/main.py).
The game is entirely written in assembly and works without either of these scripts.

## Structure

The project structure is documented in [`project.md`](project.md).

## Usage

On 64-bit macOS:

```sh
./launch
```

Pass `-h` to view usage information:

```sh
./launch -h
```

## Testing

Run `make test` to run the CLI tests, which depend on [`toml`](https://pypi.org/project/toml/).
