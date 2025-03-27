#include <stdio.h>
#include <stdlib.h>
#include <string.h>

struct TriangleRow {
    int* rowElements;
    int elementCount;
};

struct Triangle {
    struct TriangleRow* rows;
    int rowCount;
};

struct SumObject {
    int sum;
    int element;
};

struct SumResult {
    int* path;
    int sum;
};


struct Triangle* createTriangleFromFile(const char* filename) {
    FILE* file = fopen(filename, "r");
    if(!file){
        printf("Error opening file");
        return NULL;
    }

    struct Triangle* triangle = malloc(sizeof(struct Triangle));

    char line[1024];

    int rowCount = 0;

    while (fgets(line, sizeof(line), file)) {
        rowCount++;
    }

    triangle->rowCount = rowCount;
    triangle->rows = malloc(triangle->rowCount * sizeof(struct TriangleRow));

    int currentRow = 0;

    rewind(file);

    while (fgets(line, sizeof(line), file)){
        int elementCount = 0;
        char* ptr = line;
        while (*ptr) {
            if (*ptr == ','){
                elementCount++;
            }
            ptr++;
        }
        elementCount++;

        triangle->rows[currentRow].elementCount = elementCount;
        triangle->rows[currentRow].rowElements = malloc(elementCount * sizeof(int));

        char* element = strtok(line, ",");

        for (int i = 0; i < elementCount && element; i++) {
            triangle->rows[currentRow].rowElements[i] = atoi(element);
            element = strtok(NULL, ",");
        }

        currentRow++;
    }

     return triangle;
}

struct SumObject getMinSumObject(struct SumObject* sumValues, int length) {
    struct SumObject minValue = sumValues[0];

    for(int i = 0; i < length; i++) {
        if(sumValues[i].sum < minValue.sum) {
            minValue.sum = sumValues[i].sum;
        }
    }

    return minValue;
}

struct SumResult getMinPath(struct Triangle* triangle) {
    //Lefoglalok memóriát egy annak a tömbnek, amiben a legkisebb összegű utat fogom tárolni
    
    int* path = malloc(triangle->rowCount * sizeof(int));

    //Lefoglalok memóriát egy SumObject-eket tároló tömbnek is, amiben az éppen vizsgált sor előtti ciklus összegeit és
    //a hozzájuk tartozó értéket fogom tárolni
    struct SumObject* sumValues = malloc(triangle->rows[triangle->rowCount - 1].elementCount * sizeof(struct SumObject));

    //Mielőtt belépek a ciklusba feltöltöm a sumValues tömböt az utolsó sor elemeivel
    for(int k = 0; k < triangle->rows[triangle->rowCount - 1].elementCount; k++) {
        sumValues[k].sum = triangle->rows[triangle->rowCount - 1].rowElements[k];
    }

    //Ebben a ciklusban az alsó sortól kezdve végrehajtok egy jobb és bal utódra vonatkozó ellenőrzést minden elemen

    //A háromszög sorain futó ciklus
    for(int i = triangle->rowCount - 2; i >= 0; i--) {
        //A háromszög sorainak elemein futó ciklus
        for(int j = 0; j < triangle->rows[i].elementCount; j++) {
            //Olvashatóság miatt készítek egy currentElement változót
            int currentElement = triangle->rows[i].rowElements[j];

            //Le kérem a bal és a jobb utód eredeti értékét és az előző iteráció összegét
            struct SumObject leftChild = {sumValues[j].sum, triangle->rows[i+1].rowElements[j]};
            struct SumObject rightChild = {sumValues[j+1].sum, triangle->rows[i+1].rowElements[j+1]};

            //Összeadom az éppen vizsgált elemet az előző iteráció összegével
            int leftSum = currentElement + leftChild.sum;
            int rightSum = currentElement + rightChild.sum;
            
            //Ha a bal oldali összeg kisebb mint a jobb oldali vagy fordítva akkor felülírom az előző iteráció helyét az új összeggel
            //és az azt eredményező értékkel a sumValues tárolóban
            if(leftSum <= rightSum){
                sumValues[j].sum = leftSum;
                sumValues[j].element = triangle->rows[i+1].rowElements[j];
            }else if(rightSum < leftSum) {
                sumValues[j].sum = rightSum;
                sumValues[j].element = triangle->rows[i+1].rowElements[j+1];
            }
        }

        //Az út tömbbe a sumValues tömb éppeni iterációjának legkisebb összegű értéke fog bekerülni
        path[i+1] = getMinSumObject(sumValues, triangle->rows[i].elementCount).element;
    }

    //Hozzáadom az út tömbhöz és az összeghez a hároszög csúcsát
    path[0] = triangle->rows[0].rowElements[0];
    int sum = sumValues[0].sum + triangle->rows[0].rowElements[0];

    //Memória kezelés
    free(sumValues);
    
    //Elkészítek egy végeredmény objektumot és visszatérek vele
    struct SumResult result = {
        path,
        sum
    };

    return result;
}

void free_triangle(struct Triangle* triangle) {
    if (!triangle) return;
    
    for (int i = 0; i < triangle->rowCount; i++) {
        free(triangle->rows[i].rowElements);
    }
    free(triangle->rows);
    free(triangle);
}

// void print_triangle(const struct Triangle* triangle) {
//     for (int i = 0; i < triangle->rowCount; i++) {
//         printf("Row %d (%d elements): ", i, triangle->rows[i].elementCount);
//         for (int j = 0; j < triangle->rows[i].elementCount; j++) {
//             printf("%d ", triangle->rows[i].rowElements[j]);
//         }
//         printf("\n");
//     }
// }

int main() {

    struct Triangle* triangle = createTriangleFromFile("../0.dat");
    
    struct SumResult result = getMinPath(triangle);

    for(int i = 0; i < triangle->rowCount; i++) {
        printf("%d'th element: %d\n", i, result.path[i]);
    }

    printf("And the sum is: %d\n", result.sum);


    free(result.path);
    free_triangle(triangle);

    return 0;
}

//Meg lehet oldani egy rekurzívan is, de nem az volt az első gondolatom erre a feladatra, ezen kívül az iteratív megoldás könnyebben követhető
//szerintem.