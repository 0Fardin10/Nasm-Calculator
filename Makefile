# ─────────────────────────────────────────────
#  Makefile — Assembly Calculator
# ─────────────────────────────────────────────

TARGET  = calculator
SRC     = calculator.asm
OBJ     = calculator.o

all: $(TARGET)

$(OBJ): $(SRC)
	nasm -f elf64 $(SRC) -o $(OBJ)

$(TARGET): $(OBJ)
	ld $(OBJ) -o $(TARGET)

clean:
	rm -f $(OBJ) $(TARGET)

run: $(TARGET)
	./$(TARGET)

.PHONY: all clean run
