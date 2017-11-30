#include"sem.h"

#include<sys/types.h>
#include<sys/ipc.h>
#include<sys/sem.h>
#include<stdio.h>

int create_Sem(int key, int size) {
    int id;
    id = semget(key, size, IPC_CREAT | 0666);           //����size���ź���
    if (id < 0) {                                       //�ж��Ƿ񴴽��ɹ�
        printf("create sem %d,%d error\n", key, size);  //����ʧ�ܣ���ӡ����
    }
    return id;
}

void destroy_Sem(int semid) {
    int res = semctl(semid, 0, IPC_RMID, 0);            //��ϵͳ��ɾ���ź���
    if (res < 0) {                                      //�ж��Ƿ�ɾ���ɹ�
        printf("destroy sem %d error\n", semid);        //�ź���ɾ��ʧ�ܣ������Ϣ
    }
    return;
}

//int get_Sem(int key, int size) {
//    int id;
//    id = semget(key, size, 0666);                       //��ȡ�Ѿ��������ź���
//    if (id < 0) {
//        printf("get sem %d,%d error\n", key, size);
//    }
//    return id;
//}

void set_N(int semid, int index, int n) {
    union semun semopts;
    semopts.val = n;                                    //�趨SETVAL��ֵΪ1
    semctl(semid, index, SETVAL, semopts);              //��ʼ���ź������ź������Ϊ0
    return;
}

void P(int semid, int index) {
    struct sembuf sem;                                  //�ź�����������
    sem.sem_num = index;                                //�ź������
    sem.sem_op = -1;                                    //�ź���������-1ΪP����
    sem.sem_flg = 0;                                    //������ǣ�0��IPC_NOWAIT��
    semop(semid, &sem, 1);                              //1:��ʾִ������ĸ���
    return;
}

void V(int semid, int index) {
    struct sembuf sem;                                  //�ź�����������
    sem.sem_num = index;                                //�ź������
    sem.sem_op =  1;                                    //�ź���������1ΪV����
    sem.sem_flg = 0;                                    //�������
    semop(semid, &sem, 1);                              //1:��ʾִ������ĸ���
    return;
}

