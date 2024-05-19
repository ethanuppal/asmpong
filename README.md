# asmpong

![CI Badge](https://github.com/ethanuppal/asmpong/actions/workflows/ci.yaml/badge.svg)

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

This list will diminish over time as I reduce dependencies on the C/POSIX library, but likely not by much.

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

A cross-platform (that is, Intel vs. Silicon) `make` can be done using `./launch MAKE`.

## Testing

Run `make test` to run the CLI tests, which depend on [`toml`](https://pypi.org/project/toml/).

## Known Issues

The quality of the assembly is not the greatest because I have merely attempted to get the project working.
I may later return to improve it.
