#include <stdio.h>
#include <stdlib.h> //malloc, free
#include <memory.h> //memset
#include <math.h>


//MARK: -Get Center
// return 0 if there is no region
// return 1 if there is a region. in this case, center = (*cx, *cy)
int getcenter(const unsigned char* region, int nWidth, int nHeight, double* cx, double* cy)
{
    int i,j;
    int ncount = 0;
    *cx = *cy = 0.0;

    for(i = 0; i < nHeight; i++)
    {
       for(j = 0; j < nWidth; j++)
       {
           if(region[i*nWidth + j])
           {
               ncount++;
               *cx += j;
               *cy += i;
           }
       }
    }
    if(ncount == 0)
        return 0;
    *cx /= ncount;
    *cy /= ncount;
    return 1;
}


int getnosecircle(const unsigned char* nostril1, const unsigned char* nostril2, int nWidth, int nHeight, int* centerx, int* centery, int* nRadius)
{
   double cx1, cy1, cx2, cy2;
   int nret1, nret2;
   double dscale = 1.5;

   nret1 = getcenter(nostril1, nWidth, nHeight, &cx1, &cy1);
   nret2 = getcenter(nostril2, nWidth, nHeight, &cx2, &cy2);


   if(!nret1 || !nret2) {
      *centerx = nWidth/2;
      *centery = nHeight/2;
      *nRadius = nWidth/4;
      return 0;
   }

   *centerx = (cx1+cx2)/2;
   *centery = (cy1+cy2)/2;
   *nRadius = dscale*sqrt( (cx1-cx2)*(cx1-cx2) + (cy1-cy2)*(cy1-cy2) );
   return 1;
 
}

//MARK: -Get Boundary
//////////////////////////////////////////////////
// IntVec
//////////////////////////////////////////////////
typedef struct _IntVec
{
    int* pData;
    unsigned int nSize;        //# of stored data
    unsigned int nCap;        //capacity >= nSize
} IntVec;

// nCap >= 1; no verification
IntVec createIntVec(unsigned int nCap)
{
    IntVec res;
    if (nCap <= 0) nCap = 1;
    res.pData = (int*)malloc(sizeof(int) * nCap);
    res.nCap = nCap;
    res.nSize = 0;
    return res;
}

void freeIntVec(IntVec* a)
{
    if(a->pData != 0)
        free(a->pData);
    a->pData = 0;
    a->nSize = 0;
    a->nCap = 0;
}

void resizeIntVec(IntVec* a, unsigned int nCap2)
{
    unsigned int i;
    IntVec a2;

    if (nCap2 <= a->nCap) return;
    //nCap2 > a->nCap
    a2 = createIntVec(nCap2);
    for (i = 0; i < a->nSize; i++)
        a2.pData[i] = (a->pData)[i];
    a2.nSize = a->nSize;
    freeIntVec(a);

    a->pData = a2.pData;
    a->nCap = a2.nCap;
    a->nSize = a2.nSize;
}

void push_back(IntVec* a, int value)
{
    if (a->nCap < a->nSize + 1)
        resizeIntVec(a, (a->nSize + 1)*2);
    a->pData[a->nSize++] = value;
}

void printIntVec(IntVec a)
{
    unsigned int i;
    printf("pData:%p, nSize=%u, nCap=%u\n", a.pData, a.nSize, a.nCap);
    for (i = 0; i < a.nSize; i++)
        printf("data[%u]=%d, ", i, a.pData[i]);
    printf("\n");
}

void testIntVec(void)
{
    IntVec intv = createIntVec(1);
    printIntVec(intv);

    push_back(&intv, 54);
    push_back(&intv, 51);
    push_back(&intv, 50);
    push_back(&intv, 57);
    printIntVec(intv);

    push_back(&intv, 59);
    push_back(&intv, 70);
    printIntVec(intv);

    freeIntVec(&intv);
    printIntVec(intv);
}

//////////////////////////////////////////////////
// UIntVec
//////////////////////////////////////////////////

typedef struct _UIntVec
{
    unsigned int* pData;
    unsigned int nSize;        //# of stored data
    unsigned int nCap;        //capacity >= nSize
} UIntVec;

// nCap >= 1; no verification
UIntVec createUIntVec(unsigned int nCap)
{
    UIntVec res;
    if (nCap <= 0) nCap = 1;
    res.pData = (unsigned int*)malloc(sizeof(unsigned int) * nCap);
    res.nCap = nCap;
    res.nSize = 0;
    return res;
}

void freeUIntVec(UIntVec* a)
{
    if (a->pData != 0)
        free(a->pData);
    a->pData = 0;
    a->nSize = 0;
    a->nCap = 0;
}

//increase the capacity only
void resizeUIntVec(UIntVec* a, unsigned int nCap2)
{
    unsigned int i;
    UIntVec a2;

    if (nCap2 <= a->nCap) return;
    //nCap2 > a->nCap
    a2 = createUIntVec(nCap2);
    for (i = 0; i < a->nSize; i++)
        a2.pData[i] = (a->pData)[i];
    a2.nSize = a->nSize;
    freeUIntVec(a);

    a->pData = a2.pData;
    a->nCap = a2.nCap;
    a->nSize = a2.nSize;
}

void push_back_U(UIntVec* a, unsigned int value)
{
    if (a->nCap < a->nSize + 1)
        resizeUIntVec(a, (a->nSize + 1) * 2);
    a->pData[a->nSize++] = value;
}

//////////////////////////////////////////////////
// Point2DVec
//////////////////////////////////////////////////

typedef struct _UPoint2D
{
    unsigned int x;
    unsigned int y;
} UPoint2D;

typedef struct _UPoint2DVec
{
    UPoint2D* pData;
    unsigned int nSize;
    unsigned int nCap;
} UPoint2DVec;

UPoint2DVec createUPoint2DVec(unsigned int nCap)
{
    UPoint2DVec res;
    if (nCap <= 0) nCap = 1;
    res.pData = (UPoint2D*)malloc(sizeof(UPoint2D) * nCap);
    res.nCap = nCap;
    res.nSize = 0;
    return res;
}

void freeUPoint2DVec(UPoint2DVec* a)
{
    if (a->pData != 0)
        free(a->pData);
    a->pData = 0;
    a->nSize = 0;
    a->nCap = 0;
}

void resizeUPoint2DVec(UPoint2DVec* a, unsigned int nCap2)
{
    unsigned int i;
    UPoint2DVec a2;

    if (nCap2 <= a->nCap) return;
    //nCap2 > a->nCap
    a2 = createUPoint2DVec(nCap2);
    for (i = 0; i < a->nSize; i++)
        a2.pData[i] = (a->pData)[i];
    a2.nSize = a->nSize;
    freeUPoint2DVec(a);

    a->pData = a2.pData;
    a->nCap = a2.nCap;
    a->nSize = a2.nSize;
}

void push_back_UPoint2D(UPoint2DVec* a, UPoint2D value)
{
    if (a->nCap < a->nSize + 1)
        resizeUPoint2DVec(a, (a->nSize + 1) * 2);
    a->pData[a->nSize++] = value;
}


unsigned int getlabel(unsigned int* pLabel, unsigned int nIndex)
{
    while (pLabel[nIndex])
        nIndex = pLabel[nIndex];
    return nIndex;
}
void printLabel(unsigned int* pLabel, unsigned int nWidth, unsigned int nHeight)
{
    unsigned int i, j;
    for (j = 0; j < nHeight; j++) {
        for (i = 0; i < nWidth; i++) {
            printf("%2d ", pLabel[j * nWidth + i]);
        }
        printf("\n");
    }
}

unsigned int relabelmap(unsigned int* labelmap, unsigned int nSize)
{
    UIntVec temp = createUIntVec(nSize);
    push_back_U(&temp, 0);
    unsigned int i, ncomp = 0;
    for (i = 1; i < nSize; i++) {
        if (labelmap[i]) {
            push_back_U(&temp, 0);
            labelmap[i] = getlabel(labelmap, labelmap[i]);
        }
        else
            push_back_U(&temp, ++ncomp);
    }
    for (i = 1; i < nSize; i++) {
        labelmap[i] = labelmap[i] ? temp.pData[labelmap[i]] : temp.pData[i];
    }
    freeUIntVec(&temp);
    return ncomp;
}

unsigned int getCompCount(unsigned int* labelmap, unsigned int nSize)
{
    unsigned int ncomp = 0;
    unsigned int i = 0;
    for (i = 1; i < nSize; i++)
        if (!labelmap[i]) ncomp++;
    return ncomp;
}

unsigned setLabel(unsigned int* labelmap, unsigned int i)
{
    // Assumption: 0 <= i < nSize, comp[0] = 0
    if (labelmap[i])
        return (labelmap[i] = setLabel(labelmap, labelmap[i]));
    else
        return i;
}

void setLabelAll(unsigned int* labelmap, unsigned int nSize)
{
    unsigned int i = 0;
    for (i = 1; i < nSize; i++)
        setLabel(labelmap, i);
}

void printLabelmap(unsigned int* labelmap, unsigned int nSize)
{
    unsigned int i = 0;
    printf("[0]:%d\n", labelmap[i]);
    for (i = 1; i < nSize; i++)
        printf("[%d]:%d,", i, labelmap[i]);
    printf("\n");
}

//labelmap: terminal comp with 0
void relabel(unsigned int* label, unsigned int nSize1, unsigned int* labelmap, unsigned int nSize2)
{
    unsigned int i;
    for (i = 0; i < nSize1; i++)
    {
        if (label[i])
            label[i] = getlabel(labelmap, label[i]);
    }
}

//labelmap: with serial label
void relabel2(unsigned int* label, unsigned int nSize1, unsigned int* labelmap, unsigned int nSize2)
{
    unsigned int i;
    for (i = 0; i < nSize1; i++)
    {
        if (label[i])
            label[i] = labelmap[label[i]];
    }
}


//b8nbd = 1: 8-connected neighborhood,
//b8nbd = 0: 4-connected neighborhood,
unsigned int getCC(const unsigned char* pImg, unsigned int nWidth, unsigned int nHeight,
    unsigned int* label, unsigned char b8nbd)
{
    int i, k;
    unsigned int up, left;
    unsigned int ncomp = 0;
    int nSize = nWidth * nHeight;
    UIntVec labelmap = createUIntVec(10);
    push_back_U(&labelmap, 0);

    memset(label, 0, sizeof(unsigned int) * nWidth * nHeight);
    
    for (i = 0; i < nSize; i++)
    {
        if (!pImg[i]) continue;
        up = left = 0;
        k = i - nWidth; //overflow if nWidth is too big ?

        if (i % nWidth > 0) {
            if (label[i - 1])
                left = label[i - 1];
            if (b8nbd && !left && k > 0 && label[k - 1])
                left = label[k - 1];
        }

        if (k >= 0) {
            if (label[k])
                up = label[k];
            if (b8nbd && !up && i % nWidth < nWidth - 1 && label[k + 1])
                up = label[k + 1];
        }

        if (up || left) {
            up = getlabel(labelmap.pData, up);
            left = getlabel(labelmap.pData, left);
            if (up) {
                label[i] = up;
                if (left && left != up)
                    labelmap.pData[left] = up;
            }
            else
                label[i] = left;
        }
        else {
            label[i] = ++ncomp;
            push_back_U(&labelmap, 0);
        }
    }
    //printLabel(label, nWidth, nHeight);
    //printLabelmap(labelmap.pData, labelmap.nSize);

    //unsigned int ncompcount = getCompCount(labelmap.pData, labelmap.nSize);
    //printf("ncomp=%d\n", ncompcount);

    unsigned int ncompcount = relabelmap(labelmap.pData, labelmap.nSize);
    //printf("ncomp(2)=%d\n", ncompcount);


    ////setLabelAll(labelmap.pData, labelmap.nSize);
    //printLabelmap(labelmap.pData, labelmap.nSize);

    ////relabel(label, nWidth * nHeight, labelmap.pData, labelmap.nSize);

    relabel2(label, nWidth * nHeight, labelmap.pData, labelmap.nSize);
    //printLabel(label, nWidth, nHeight);
    freeUIntVec(&labelmap);

    return ncompcount;
}

void testCC01(void)
{
    unsigned char img[] = { 0,1,0,1,
                            0,1,0,1,
                            0,0,1,0 };
    const unsigned int nWidth = 4;
    const unsigned int nHeight = 3;
    unsigned int label[4*3] = { 0, };
    unsigned char b8nbd = 0;
    unsigned int ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");

    b8nbd = 1;
    ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");
}

void testCC02(void)
{
    unsigned char img[] = { 0,1,0,0,
                            0,1,0,1,
                            0,0,1,1,
                            0,1,0,0};
    const unsigned int nWidth = 4;
    const unsigned int nHeight = 4;
    unsigned int label[4 * 4] = { 0, };
    unsigned char b8nbd = 0;
    unsigned int ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");

    b8nbd = 1;
    ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");
}

void testCC03(void)
{                         //1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8
    unsigned char img[] = {
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,
                            0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,0,
                            0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,
                            0,0,1,1,1,1,0,0,0,1,1,1,0,0,1,1,0,
                            0,1,1,1,0,0,1,1,0,0,0,1,1,1,0,0,0,
                            0,0,1,1,0,0,0,0,0,1,1,0,0,0,1,1,0,
                            0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                            };
    const unsigned int nWidth = 17;
    const unsigned int nHeight = 9;
    unsigned int label[17 * 9] = { 0, };
    unsigned char b8nbd = 0;
    unsigned int ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");

    b8nbd = 1;
    ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");
}

////////////////////////////////////////////////////
//    3 2 1
//    4   0
//    5 6 7
//////////////
#define NBD 8
#define HNBD 4
//                        0, 1, 2, 3, 4, 5, 6, 7
static int x8nbd[NBD] = { 1, 1, 0,-1,-1,-1, 0, 1 };
static int y8nbd[NBD] = { 0,-1,-1,-1, 0, 1, 1, 1 };
#define REFDIR(a) (((a)+HNBD)%NBD)
#define NEXT(a) (((a)+1)%NBD)


UPoint2DVec traceBoundary(unsigned int* label, unsigned int nWidth, unsigned int nHeight,
    UPoint2D st, int startFrom)
{
    unsigned int compIdx = label[st.x + st.y * nWidth];
    UPoint2DVec ptVec = createUPoint2DVec(100);
    if (!compIdx) return ptVec;
    UPoint2D nextPt = st;
    unsigned int i = 0;
    int k, x, y, x2, y2;

    do {
        push_back_UPoint2D(&ptVec, nextPt);
        x = nextPt.x;
        y = nextPt.y;
        k = startFrom;
        for (i = 0; i < NBD; i++) {
            k = NEXT(k);
            x2 = x + x8nbd[k];
            y2 = y + y8nbd[k];
            if (0 <= x2 && x2 < nWidth && 0 <= y2 && y2 < nHeight
                && label[x2 + y2 * nWidth] == compIdx) {
                nextPt.x = x2;
                nextPt.y = y2;
                startFrom = REFDIR(k);
                break;
            }
        }
    } while (nextPt.x != st.x || nextPt.y != st.y);

    return ptVec;
}

//if there is no comp with compIdx, return (0,0)
UPoint2D findTopLeftPt(unsigned int* label, unsigned int nWidth, unsigned int nHeight, unsigned int compIdx)
{
    UPoint2D pt;
    unsigned int i, j;
    pt.x = pt.y = 0;

    for (j = 0; j < nHeight; j++) {
        for (i = 0; i < nWidth; i++) {
            if (label[i + j * nWidth] == compIdx) {
                pt.x = i;
                pt.y = j;
                return pt;
            }
        }
    }
    return pt;
}

UPoint2DVec extractBoundary(unsigned int* label, unsigned int nWidth, unsigned int nHeight, unsigned int compIdx)
{
    UPoint2D start;
    start = findTopLeftPt(label, nWidth, nHeight, compIdx);
    UPoint2DVec ptVec;

    ptVec = traceBoundary(label, nWidth, nHeight, start, 0);

    return ptVec;
}

void printBoundary(unsigned int* label, unsigned int nWidth, unsigned int nHeight, UPoint2DVec ptVec)
{
    unsigned int i = 0, k;
    unsigned int* ptemp = 0;
    ptemp = (unsigned int*)malloc(sizeof(unsigned int) * nWidth * nHeight);
    if(ptemp)
        memset(ptemp, 0, sizeof(unsigned int) * nWidth * nHeight);
    for (i = 0; i < ptVec.nSize; i++) {
        k = ptVec.pData[i].x + ptVec.pData[i].y * nWidth;
        printf("(%3u,%3u):%2u\n", ptVec.pData[i].x, ptVec.pData[i].y, label[k]);
        if(ptemp)
            ptemp[k] = label[k];
    }
    
    if (ptemp) {
        printf("\n");
        printLabel(ptemp, nWidth, nHeight);
        printf("\n");
        free(ptemp);
    }
}

void testExtractBoundary01(void)
{                          //1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8
    unsigned char img[] = {
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                            0,0,1,1,0,0,1,1,0,0,1,1,0,0,1,1,0,
                            0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,0,
                            0,0,0,1,1,1,1,0,0,0,1,1,1,1,0,0,0,
                            0,0,1,1,1,1,0,0,0,1,1,1,0,0,1,1,0,
                            0,1,1,1,0,0,1,1,0,0,0,1,1,1,0,0,0,
                            0,0,1,1,0,0,0,0,0,1,1,0,0,0,1,1,0,
                            0,0,0,0,0,0,1,1,1,1,0,0,1,1,1,1,0,
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
    };
    const unsigned int nWidth = 17;
    const unsigned int nHeight = 9;
    unsigned int label[17 * 9] = { 0, };
    unsigned char b8nbd = 1;

    unsigned int ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");

    unsigned int compIdx = 1; // 1 <= compIdx <= ncomp
    UPoint2DVec ptVec = extractBoundary(label, nWidth, nHeight, compIdx);
    printBoundary(label, nWidth, nHeight, ptVec);

    freeUPoint2DVec(&ptVec);
}

void testExtractBoundary02(void)
{                          //1,2,3,4,5,6,7,8,9,0,1,2,3,4,5,6,7,8
    unsigned char img[] = {
                            0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,
                            0,0,1,1,0,0,1,1,0,0,1,1,0,1,1,1,0,
                            0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,0,0,
                            0,0,1,1,1,1,1,1,1,0,1,1,1,1,1,0,0,
                            0,0,1,1,1,1,0,0,0,1,1,1,0,1,1,1,0,
                            0,1,1,1,1,1,1,1,1,0,0,1,1,1,1,1,0,
                            0,0,1,1,1,0,0,1,1,1,1,1,1,1,1,1,0,
                            0,0,1,1,0,0,1,1,1,1,0,1,1,1,1,1,0,
                            0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0
    };
    const unsigned int nWidth = 17;
    const unsigned int nHeight = 9;
    unsigned int label[17 * 9] = { 0, };
    unsigned char b8nbd = 1;

    unsigned int ncomp = getCC(img, nWidth, nHeight, label, b8nbd);
    printf("n8nbd=%d, ncomp=%d\n", b8nbd, ncomp);
    printLabel(label, nWidth, nHeight);
    printf("\n");

    unsigned int compIdx = 1; // 1 <= compIdx <= ncomp
    UPoint2DVec ptVec = extractBoundary(label, nWidth, nHeight, compIdx);
    printBoundary(label, nWidth, nHeight, ptVec);

    freeUPoint2DVec(&ptVec);
}

//int main(void)
//{
//    printf("Hello, World!\n");
//    //testIntVec();
////    testCC01();
////    testCC02();
////    testCC03();
//
////    testExtractBoundary01();
//    testExtractBoundary02();
//}

