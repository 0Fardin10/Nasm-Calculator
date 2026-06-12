# 🖩 Assembly Calculator

A simple command-line calculator written in **x86-64 NASM Assembly** for Linux.  
Supports addition, subtraction, multiplication, and division — including negative numbers.

---

## ✨ Features

- ➕ Addition
- ➖ Subtraction
- ✖️ Multiplication
- ➗ Division (with divide-by-zero protection)
- Handles **negative numbers**
- Pure assembly — **no C library**, no external dependencies

---

## 🛠️ Requirements

| Tool | Install |
|------|---------|
| NASM | `sudo apt install nasm` |
| ld (GNU linker) | Usually pre-installed (`binutils`) |
| Linux x86-64 | Any modern 64-bit Linux distro |

---

## 🚀 Build & Run

```bash
# Clone the repo
git clone https://github.com/YOUR_USERNAME/asm-calculator.git
cd asm-calculator

# Build using Makefile
make

# Run
./calculator
```

Or manually:

```bash
nasm -f elf64 calculator.asm -o calculator.o
ld calculator.o -o calculator
./calculator
```

---

## 📸 Demo

```
Enter first number : 25
Enter operator (+,-,*,/) : /
Enter second number: 5
Result = 5
```

```
Enter first number : -10
Enter operator (+,-,*,/) : +
Enter second number: 3
Result = -7
```

---

## 📁 Project Structure

```
asm-calculator/
├── calculator.asm   # Main source file
├── Makefile         # Build automation
├── .gitignore       # Ignores build artifacts
└── README.md        # This file
```

---

## 🧠 How It Works

| Routine | Description |
|---------|-------------|
| `str_to_int` | Converts ASCII input string to 64-bit integer |
| `int_to_str` | Converts 64-bit integer result to printable string |
| Linux syscalls | Uses `read` (0), `write` (1), `exit` (60) — no libc |

---

## 📜 License

MIT License — free to use, modify, and distribute.

---

## 👤 Author

**Fardin Zabir**  
CSE Student — World University of Bangladesh  
GitHub: [0Fardin10](https://github.com/YOUR_USERNAME)
