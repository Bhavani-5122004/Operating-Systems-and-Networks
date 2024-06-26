import matplotlib.pyplot as plt

# Your data
data1 = [
    (0, 34), (0, 35), (0, 36), (0, 37), (0, 37), (0, 38), (0, 40), (1, 41),
    (2, 42), (9, 49), (10, 50), (11, 52), (13, 54), (14, 55), (15, 57), (17, 59),
    (18, 60), (19, 62), (21, 64), (22, 65), (23, 67), (25, 69), (26, 70), (27, 72),
    (29, 74), (30, 75), (31, 77), (33, 79), (34, 80), (35, 82), (37, 84), (38, 85),
    (39, 87), (41, 89), (42, 90), (43, 92), (45, 94), (46, 95), (47, 97), (49, 99),
    (49, 100), (50, 102), (52, 104), (53, 105), (54, 107), (55, 109), (56, 110), (57, 112),
    (59, 114), (60, 115), (61, 117), (63, 119), (64, 120), (65, 122), (67, 124), (68, 125),
    (69, 127), (71, 129), (72, 130), (73, 132), (75, 134), (76, 135), (77, 137), (78, 138)
]

data2 = [
    (0, 78), (2, 81), (2, 82), (2, 83), (3, 85), (3, 86), (4, 88), (4, 89),
    (5, 91), (6, 93), (6, 94), (7, 96), (8, 98), (8, 99), (9, 101), (10, 103),
    (10, 104), (11, 106), (12, 108), (12, 109), (13, 111), (14, 113), (14, 114), (15, 116),
    (16, 118), (16, 119), (17, 121), (18, 123), (18, 124), (19, 126), (20, 128), (20, 129),
    (21, 131), (22, 133), (22, 134), (23, 136), (24, 138), (24, 139), (25, 141), (26, 143),
    (26, 144), (27, 146), (28, 148), (28, 149), (29, 151), (30, 153), (30, 154), (31, 156),
    (32, 158), (32, 159), (33, 161), (34, 163), (34, 164), (35, 166), (36, 168), (36, 169),
    (37, 171), (38, 173), (38, 174), (39, 176), (39, 177), (39, 179), (40, 181), (41, 183),
    (41, 184), (42, 186), (43, 188), (43, 189), (44, 191), (45, 193), (45, 194), (46, 196),
    (47, 198), (47, 199), (47, 200), (47, 201), (47, 202), (47, 203), (47, 204), (47, 205),
    (47, 206), (47, 207), (47, 208), (47, 209), (47, 210), (47, 211), (47, 212), (47, 213),
    (47, 214), (47, 215), (47, 216), (47, 217), (47, 218), (47, 219), (47, 220), (47, 221),
    (47, 222), (47, 223), (47, 224), (47, 225), (47, 226), (47, 227), (47, 228), (47, 229),
    (47, 230), (47, 231), (47, 232), (47, 233), (47, 234), (47, 235), (47, 236), (47, 237),
    (47, 238), (47, 239), (47, 240), (47, 241), (47, 242), (47, 243), (47, 244), (47, 245),
    (47, 246), (47, 247), (47, 248), (47, 249), (47, 250), (47, 251), (47, 252), (47, 253),
    (47, 254), (47, 255), (47, 256), (47, 257), (47, 258), (47, 259), (47, 260), (47, 261),
    (47, 262), (47, 263), (47, 264), (47, 265), (47, 266), (47, 267), (47, 268), (47, 269),
    (47, 270), (47, 271), (47, 272), (47, 273), (47, 274), (47, 275), (47, 276), (47, 277),
    (47, 278)
]

fig, axs = plt.subplots(2, 1, figsize=(10, 8))

y_values1, x_values1 = zip(*data1)
y_values2, x_values2 = zip(*data2)

axs[0].plot(x_values1, y_values1, linestyle='-')
axs[0].set_xlabel('Number of Ticks')
axs[0].set_ylabel('Waiting time')
axs[0].set_title('Waiting time vs time graph for process with pid = 9 (CPU Bound)')

axs[1].plot(x_values2, y_values2, linestyle='-')
axs[1].set_xlabel('Number of Ticks')
axs[1].set_ylabel('Waiting time')
axs[1].set_title('Waiting time vs time graph for process with pid = 4 (I/O Bound)')

plt.tight_layout()
plt.show()
