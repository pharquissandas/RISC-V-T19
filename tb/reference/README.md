# PDF Program Verification Documentation
## Author: Preet Harquissandas 

This document details the operation, memory architecture, verification procedure, and technical challenges overcome for the **Probability Distribution Function (PDF) program** (`pdf.s`), which is used as a critical functional test for the RISC-V CPU.

---

## 1. Program Overview (`pdf.s`)

The `pdf.s` assembly program calculates the frequency distribution of an 8-bit signal contained in the data memory. The program iterates through $65,536$ input samples and increments a counter (or "bin") for each unique value, effectively creating a histogram.

| Component | Function | Status Register |
| :--- | :--- | :--- |
| **Input Data** | Stores $65,536$ 8-bit signal samples. | Loaded from Data Memory (DM) |
| **PDF Array** | Stores the 256 output bins (frequency counts). | Stored in DM, read by **`a0`** for plotting |
| **Stop Condition** | Program halts when any bin count reaches $255$. | Handled by conditional branch in `pdf.s` |

---

## 2. Memory Architecture & Initialization

Correct memory mapping and initialization were critical to running this program successfully. The `pdf.s` program adheres strictly to the defined memory map:

| Memory Region | Address Range | Size | Purpose | Initialization |
| :--- | :--- | :--- | :--- | :--- |
| **PDF Array** (Output) | $0\text{x00000100}$ to $0\text{x000001FF}$ | 256 bytes | Stores the calculated bin counts (0-255). | Initialized to **zero** by the `init` routine in `pdf.s`. |
| **Data Samples** (Input) | $0\text{x00010000}$ to $0\text{x0001FFFF}$ | $65,536$ bytes | Stores the data set (`gaussian.mem`, `sine.mem`, etc.). | Loaded via `$readmemh` in Verilog/SystemVerilog. |

### 2.1. Critical Memory Initialization Fix (Bug Fix)

**Problem:** Initial attempts to run the PDF program resulted in the CPU reading only zero values, leading to a constant, flat PDF output. The CPU logic was correct, but the memory data was not accessible.

**Root Cause:** The Verilator test harness was initializing the Data Memory array starting at address $0\text{x00000000}$. Since the input data is mapped to start at the high address $0\text{x00010000}$, the CPU was effectively reading uninitialized memory.

**Solution:** The `$readmemh` directive in the Data Memory module (`data_mem.v`) was updated to include the necessary address offset:

```verilog
$readmemh("data.hex", data_array, 32'h00010000); // CRITICAL OFFSET
```

## 3. Verification and Plotting (`pdf_tb.cpp`)

The C++ testbench (`pdf_tb.cpp`) was significantly optimized to provide accurate and persistent visual evidence of the PDF calculation using the Vbuddy interface.

### 3.1. Dynamic Visualization Optimization

The plotting logic was made robust to handle continuous data output from the CPU and render the optimal visual representation for each type of distribution.

| Feature | Description | Technical Implementation |
| :--- | :--- | :--- |
| **Input Flexibility** | The testbench dynamically reads the input filename (e.g., `gaussian.mem`) to set the header and optimize plotting settings. | Uses `std::string` and command line arguments (`argv[1]`). |
| **Robust Plotting Logic** | Prevents multiple plots per cycle, ensuring a smooth histogram update exactly once per calculated bin count. | Plots only when the output register `top->a0` changes value (`current_a0 != prev_a0`). |
| **Dynamic Vbuddy Mode** | Selects the optimal Vbuddy mode for the data type. | **Mode 1 (Bar Graph)** for discrete data (Gaussian, Noisy). **Mode 0 (Line Plot)** for continuous signals (Sine, Triangle).  |
| **Dynamic Y-Axis Scaling** | Adjusts the maximum plot height to ensure shorter distributions (like the Sine wave PDF's U-shape) appear prominent. | Y-axis maximum is set dynamically based on the input file name (e.g., $250$ for Sine, $300$ for Gaussian). |
| **Persistent Display** | The simulation continues to run indefinitely after the PDF is completed, holding the final image on the Vbuddy screen. | Removed the $256$-bin cycle break condition, allowing the simulation to continue until the user presses 'q'. |

### 3.2. Interpreting the Results

The PDF output must be interpreted statistically, not as a time-series plot.

| Data File | Expected PDF Shape | Statistical Reason |
| :--- | :--- | :--- |
| `gaussian.mem` | **Bell Curve** (Single peak in the center).  | Data samples are concentrated around the mean value. |
| `noisy.mem` | **Complex/Bimodal** (Multi-peaked or wide distribution). | Data samples are spread across multiple centers, typical of mixed signals. |
| `sine.mem` | **U-Shape** (Two tall peaks at the extremes, low count in the middle).  | The signal spends most time at its minimum and maximum values (peaks/troughs), resulting in high frequency counts at $0$ and $255$. |
| `triangle.mem` | **Flat/Uniform** (All bars roughly the same height).  | The signal's linear slope ensures it spends an equal amount of time at every value between $0$ and $255$. |

---

## 4. Execution Procedure

The consolidated `pdf.sh` script is used to execute the program against any reference data file and apply the necessary plotting optimizations.
### 1. Vbuddy Setup and Connection

To use the Vbuddy for visualization (required for the PDF program and F1 lights), you must first establish the USB connection and identify the correct device port. This must be done from within the `tb` directory.

1.  **Navigate to the testbench folder:**
    ```bash
    cd tb
    ```

2.  **Run the connection script:**
    ```bash
    ./attach_usb.sh
    ```

#### Step 1: Set up the Vbuddy interface

Connect Vbuddy to your computer's USB port using a USB cable provided. Find out the name of the USB device used. How? This depends on whether you are using a MacBook or a PC.

**Macbook Users**
For Mac users, enter:
```bash
ls /dev/tty.u*
```

You should see a device name similar to this:
`/dev/tty.usbserial-110`

**Window Users (using WSL)**
Run the following script:
```bash
~/Documents/iac/lab0-devtools/tools/attach_usb.sh
```
This uses `usbipd` to search for the USB port that Vbuddy is connected to and share it with WSL.  **The script must be run every time Vbuddy is reconnected to the computer.** You may wish to include this in your `doit.sh` script so that it runs automatically every time you run your code.

Next enter the following command to find the name of your device:
```bash
ls /dev/ttyU*
```

You should see a device name similar to this:
`/dev/ttyUSB0`

**Configuration File**
Create a file: **`vbuddy.cfg`**, which contains the device name as the only line (terminated with CR). You may use VS Code or the Linux `nano` editor to do this. You should only have to do this once, as the device name will usually be the same when Vbuddy is reconnected.
This should already exist in the repo already

---

### 2. Run PDF Verification (Example Commands)

Once the Vbuddy is connected and the model is built, use the consolidated `pdf.sh` script to run the PDF program against the reference data files.

| Distribution | Command |
| :--- | :--- |
| **Gaussian** (Default Test) | `./pdf.sh reference/gaussian.mem` |
| **Noisy** (Complex Data) | `./pdf.sh reference/noisy.mem` |
| **Triangle** (Uniform PDF) | `./pdf.sh reference/triangle.mem` |
| **Sine** (U-Shaped PDF) | `./pdf.sh reference/sine.mem` |

## 5. Process Behind `sine.mem`

The `sine.mem` file, used to test the CPU's PDF calculation against a U-shaped distribution, was generated by a custom Python script. This script ensures the input data perfectly adheres to the expected $65,536$ 8-bit sample format required by the `pdf.s` assembly program.

<img width="690" height="765" alt="sine made" src="https://github.com/user-attachments/assets/904341d4-bca8-430a-a63a-f5fa6e5f3964" />

### 5.1. Code Explanation

The script calculates a sinusoidal signal, scales it to the 8-bit range, and outputs the values as hexadecimal data suitable for loading into the Data Memory.

| Line(s) | Variable/Section | Description |
| :--- | :--- | :--- |
| **L5** | `NUM_SAMPLES = 65536` | Defines the total number of samples (64KB) required by the `pdf.s` program's loop count. |
| **L6** | `NUM_CYCLES = 64` | Sets the number of full sine wave oscillations to be generated across the entire sample set. |
| **L11-12** | `AMPLITUDE = 127.0`, `OFFSET = 128.0` | These values scale and shift the standard $[-1, 1]$ sine output to the $0$ to $255$ range: $\text{Value} = 127 \times \sin(\theta) + 128$. |
| **L21** | `angle = (i / NUM_SAMPLES) * 2 * math.pi * NUM_CYCLES` | Calculates the angle for the current sample $i$, ensuring $64$ cycles are completed precisely at the end of $65,536$ samples. |
| **L24** | `sine_value = AMPLITUDE * math.sin(angle) + OFFSET` | Generates the floating-point sine value, scaled and offset to the correct range. |
| **L27-28** | `sample = int(round(sine_value))` `sample = max(0, min(255, sample))` | Converts the floating-point value to an integer, then clips the result to the guaranteed 8-bit range $[0, 255]$. |
| **L36-37** | `f.write(f"{sample:02x}\n")` | **Output Formatting:** Writes each 8-bit sample as a **2-digit hexadecimal value** (`02x`), one per line, which is the required format for the Data Memory initializer (`$readmemh`). |

### 5.2. Verification Relevance

The `sine.mem` file is crucial for demonstrating that the CPU correctly handles complex statistical calculations.

* **Expected Behavior:** A sine wave spends most of its time near its minimum and maximum peaks.
* **Verification:** When the CPU runs the `pdf.s` program with `sine.mem` as input, the resulting Vbuddy plot must show a distinct **U-shape** (high bars at $0$ and $255$, low bars in the middle), confirming the logic of the `pdf.s` calculation and the accuracy of the memory load operation. ```
