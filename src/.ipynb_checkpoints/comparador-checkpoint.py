import numpy as np
import subprocess
import matplotlib.pyplot as plt


def correr_instancia(filtro, archivo_entrada, implementacion, cant_iteraciones = '2'):
    result = subprocess.run(['./build/tp2', filtro, archivo_entrada, '-i', implementacion, '-t', cant_iteraciones], capture_output=True,  encoding='utf-8')
    # print(result)
    output = result.stdout.split('\n')[:-1]
    output = output[4]
    return np.array(list(map(int, output.split(','))))


if __name__ == '__main__':
    ticksC = correr_instancia('Max', 'img/HardCandy.bmp', 'c')
    ticksASM = correr_instancia('Max', 'img/HardCandy.bmp', 'asm')
    plt.boxplot(ticksC)
    plt.boxplot(ticksASM)
    plt.show()