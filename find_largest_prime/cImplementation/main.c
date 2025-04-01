#include <stdio.h>

// Ez volt a legelső feladat amit csináltam utólag visszanézve bánom hogy C-ben de itt még féltem a hack-től
// Itt még iteratív módszert alkalmaztam mert jobban átláttam az iteratív mélységi keresést ezt sem csinálnám már ugyanígy
// a get_primes_product feladatban már rekurzívan jártam be a mátrixot

struct Node
{
    int i, j;
    int parentValue;
};

int checkPrime(int num)
{
    // Először megnézem hogy a szám kisebb-e mint 2. Ha kettőnél kisebb akkor rögtön hamis értékkel térek vissza, mert
    // 1. Negatív prímszám nem létezik
    // 2. A 0 és az 1 nem prímszám
    if (num < 2)
    {
        return 0;
    }

    // Ha a szám nagyobb mint 1, akkor 2-től a számig terjedő értékeken végig iterálok és ellenőrzöm hogy a szám osztható-e ezekkel az értékekkel.
    // Ha igen, akkor a szám nem prímszám.
    // Csak a számig megyek a ciklusban, mert bármely a számnál nagyobb érték nem eredményezne egész számot az osztásban (Minden prímszám egész szám).
    for (int i = 2; i < num; i++)
    {
        if (num % i == 0)
        {
            return 0;
        }
    }

    return 1;
}

int getBiggestPrime(int rows, int cols, int matrix[rows][cols])
{

    // Deklarálok egy currentBiggest változót amiben az éppeni legnagyobb prím szám értékét fogom tárolni. Ezt kezdetileg -1-re állítom,
    // hogy ha nem talál az algoritmus semmilyen prím számot a mátrixban akkor a -1-es értéket vissza tudja adni.
    int currentBiggest = -1;

    // Elindítok 2 darab egymásba ágyazott ciklust, amik a mátrix indexein fognak végig iterálni. Minden érténél lefuttatom az előbb definiált
    // checkPrime függvényt, és ha igazzal tér vissza még leellenőrzöm, hogy nagyobb-e az érték mint az eddigi legnagyobb prím. Ha igen akkor ez
    // a szám lesz az új legnagyobb prím.
    for (int i = 0; i < rows; i++)
    {
        for (int j = 0; j < cols; j++)
        {
            if (checkPrime(matrix[i][j]) && (matrix[i][j] > currentBiggest))
            {
                currentBiggest = matrix[i][j];
            }
        }
    }

    // Ezek után deklarálok egy stacket, amiben a bejárt indexeket és az előttük járó értéket fogom tárolni
    struct Node stack[rows * cols];
    int top = 0;

    stack[top++] = (struct Node){0, 0, 0};

    while (top > 0)
    {
        // Minden ciklus kezdetén pop-olom a stacket
        struct Node node = stack[--top];
        int i = node.i;
        int j = node.j;

        // Konkatenálom az éppen vizsgált elem értékét az előtte járó értékkel
        int currentValue = node.parentValue * 10 + matrix[i][j];

        // Ellenőrzöm, hogy az ebből eredő új vizsgált érték prímszám-e és ha igen, akkor ezt állítom be a legnagyobb prímszámnak
        if (checkPrime(currentValue))
        {
            if (currentValue > currentBiggest)
            {
                currentBiggest = currentValue;
            }
        }

        // Ha lehetséges akkor beleteszem a stack-be a jobb és alsó elem indexét az ebben a ciklusban generált számmal együtt
        if (j + 1 < cols)
        {
            stack[top++] = (struct Node){i, j + 1, currentValue};
        }

        if (i + 1 < rows)
        {
            stack[top++] = (struct Node){i + 1, j, currentValue};
        }
    }

    return currentBiggest;
}

int main()
{
    int matrix[3][3] = {{5, 2, 5}, {4, 7, 0}, {6, 7, 9}};
    printf("The biggest prime number in the matrix is: %d", getBiggestPrime(3, 3, matrix));

    return 0;
}