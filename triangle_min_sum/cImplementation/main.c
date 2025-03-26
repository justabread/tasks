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
    int* path = malloc(triangle->rowCount * sizeof(int));
    struct SumObject* sumValues = malloc(triangle->rows[triangle->rowCount - 1].elementCount * sizeof(struct SumObject));

    for(int k = 0; k < triangle->rows[triangle->rowCount - 1].elementCount; k++) {
        sumValues[k].sum = triangle->rows[triangle->rowCount - 1].rowElements[k];
    }

    for(int i = triangle->rowCount - 2; i >= 0; i--) {
        for(int j = 0; j < triangle->rows[i].elementCount; j++) {
            int currentElement = triangle->rows[i].rowElements[j];


            struct SumObject leftChild = {sumValues[j].sum, triangle->rows[i+1].rowElements[j]};
            struct SumObject rightChild = {sumValues[j+1].sum, triangle->rows[i+1].rowElements[j+1]};

            int leftSum = currentElement + leftChild.sum;
            int rightSum = currentElement + rightChild.sum;
            
            if(leftSum <= rightSum){
                sumValues[j].sum = leftSum;
                sumValues[j].element = triangle->rows[i+1].rowElements[j];
            }else if(rightSum < leftSum) {
                sumValues[j].sum = rightSum;
                sumValues[j].element = triangle->rows[i+1].rowElements[j+1];
            }
        }

        path[i+1] = getMinSumObject(sumValues, triangle->rows[i].elementCount).element;
    }

    path[0] = triangle->rows[0].rowElements[0];
    int sum = sumValues[0].sum + triangle->rows[0].rowElements[0];

    free(sumValues);
    
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

//ÖSSZES MALLOCOT ELLENŐRIZNI HOGY FEL LETTEK E SZABADÍTVA