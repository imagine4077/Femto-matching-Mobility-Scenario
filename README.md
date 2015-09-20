README
================

#### Profile

Femto-matching is a offloading algorithm that proposed by Pro. Wei Wang et al.(NJU)

#### Reference

**Wang W, Wu X, Xie L, et al. Femto-matching: Efficient traffic offloading in heterogeneous cellular networks[C]//Computer Communications (INFOCOM), 2015 IEEE Conference on. IEEE, 2015: 325-333.**


#### һ������

1. ���������ۿ������ʵ��,�ֱ��� 3 �ۡ�5 �ۺͲ����ۡ�

2. ����ÿ���ۿ�:LOOP = 1000,������ÿ���ۿ�,�ֱ��� 1000 �ζ����������ʵ�顣

3. ����ÿ�Ρ�����������ء�ʵ��:���� 11 ��ʵ��,�� femtocell �ֱ�Ϊ 50��60...150 ��11 ��ʵ�顣femtocell = 50 ʱ,����õ� femtocell λ�ü� �� user λ�ü�,�ֱ���Ϊ femto_set�� user_set ��femtocell = 60 ʱ,�� femtocell = 50 �� femto_set �� user_set ��������������� 10�� femtocell �Լ� 50(�� 60)��user��femtocell = 50 ʱ���û�����ԭ�еĳ�ʼλ�ú��ƶ���ʽ��

4. ����ÿ��ʵ��(��ĳһ femtocell �ܶ��µ�ʵ��):numloop = 300,��ÿ���û����ƶ�300 �����û�ÿ�ƶ�һ��,�㷨����һ�μ�顣�����㷨�ļ�ⷽ�������ġ�
#### ����College
**(һ)��������:**
1. ÿ�ƶ�һ��,�鿴ϵͳ�и��û����,ѡ����������û�:
	a. �������û�
	b. �߳�ԭ��վ���Ƿ�Χ���û�
���������û����롰�������û�����(����������Ϊ moved_point)��
2. ���ڡ��������û������е��û�:
    (a)�Ѽ���ϣ������� BS(ѡ�������������Ļ�վ)��
    (b)���˻�վδ����,��ֱ�ӽ���,�������û��Ƴ����������û�����;
    (c)������,�����ѽ���� quota(��������û�����)���û��Ա�:
    (c-1)�������������ǰ quota ��,�����,���߳����������û�,���߳��û������롰�������û�������,�������û��Ƴ����������û�������
    (d-2)������û���Ž�ǰ quota ��,�򽫴��û���˻�վ�ľ�����Ϊ inf��
3. ִ�в��� 2 ֱ������(���������˲��ٱ仯,�����κ��û��������� BS ������Ϊ inf)��
#### ����RAT-game
**(һ)��������:**
1. ÿ�ƶ�һ��,�鿴ϵͳ�и��û����,ѡ����������û�:
    (a)�������û�
    (b)�߳�ԭ��վ���Ƿ�Χ���û�
2. ���������û����롰�������û�����(����������Ϊ moved_point)��2�����ڡ��������û������е��û�:
    (a)ͨ�����������û���� BS �� rate��
    (b)�Ѽ���ϣ������� BS(���ݽ��������վ���ܻ�õ� rate ������,ѡ���ֵ��ߵ� BS)��
    (c)���˻�վδ����,��ֱ�ӽ���;
    (d)������,�����ѽ���� quota(��������û�����)���û��Ա�:
        (d-1)�� rate ���Ž�ǰ quota ��,�����,���߳� rate ��͵��û�,���߳��û������롰�������û������С�
        (d-2)�� rate û���Ž�ǰ quota ��,�򽫴��û���˻�վ�ľ�����Ϊ inf��
3. ִ�в��� 2 ֱ������(���������˲��ٱ仯,�����κ��û��������� BS ������Ϊ inf)��
**(��)ϸ��:**
1. �� college ��һ��������,��ǰ�û�(���֮Ϊ U1),�� U1 �������Ȩ,college �ὫU1 �Ƴ����������û�����;�� RAT-game �Խ� U1 �����ڡ��������û������������Ƶ�ԭ����:���ǵ� RAT-game ���ƶ��汾���㷨��,�û���̬��ѡ�����ŵĻ�վ(���� U1 ����ĳ��վ�� U2 Ҳ�����˴˻�վ,��ʱ U1 �ɷֵõ� rate ����Ԥ��,����ʱ�ַ����и��õĻ�վ,�� U1 ѡ�������õ�)����� mobile �汾�㷨��������:
    (a)���ƶ��汾��,��ĳ��վ����,�򲻿��Ǵ˻�վ;�ƶ��汾��,��ʹ��wanted_BS������,�Իῼ�ǽ��롣
    (b)���ƶ��汾��,ÿ���û����ڲ�ͣѰ�Ҹ��Ż�վ;�ƶ��汾��,ֻ�С��������û������е��û�Ѱ�Ҹ��Ż�վ(���û� U1 ����ʱ,�ڽ���ļ�����ʱ�������ڻỷ������Ѱ�����,��ȷ��������������л���վ)��
#### �ġ�Femto-matching
**(һ)��������:**
1. ÿ�ƶ�һ��,�鿴ϵͳ�и��û����,ѡ����������û�:
    (a)�������û�
    (b)�߳�ԭ��վ���Ƿ�Χ���û�
���������û����롰�������û�����(����������Ϊ moved_point)�����ڡ��߳�ԭ��վ���Ƿ�Χ���û���,����ԭ���� VBS �� price �µ�����ʼ״̬( -w*log2(( i-1)^(i-1)/i^i))
2. ��¼��ʱ������(assignment),��Ϊ��ori_ass��
3. ���ڡ��������û������е��û�:
    (a)����� BS ���ڴ��û�(�� U1 Ϊ��)�� margin,�� ori_ass(U1)��Ϊ��(��������),�� ori_ass(U1)�� U1 ���ۡ������ʾ:
	margin=lograte(:,U1)-curprice;
	if ori_ass(U1) ~= 0 %��֮ǰ������,����ԭ���ӻ�վ���ܴ���
		margin(ori_ass(U1))=lograte(ori_ass(U1),U1)-discount*curprice(ori_ass(U1));
	end
    (b)�û��Ѽ��� margin ��ߵ� BS,�ʹθߵ� BS������� margin С�ڵ��� 0,����û��޷����ӡ�
    (c)����� margin ���� 0,������ margin ��Ӧ�� BS ��� bid,BS ѡ�� bid ��ߵ��û������Ӧ�� VBS,������ VBS �ļ۸���� bid ��
    (d)���ѽ������ӵ��û��Ƴ����������û�����,������ c ������ VBS ԭ�����û�ռ��,���� c ����ԭռ���߱��߳�,���߳����û������������������û�������
4. ִ�в��� 3 ֱ������(���������˲��ٱ仯)��
#### �塢���ݸ�ʽ
1. ÿ 33 ��Ϊһ��,ÿ���ԡ�\n���ָ���
2. ÿ�� 1 �� 11 ��Ϊ college ����(N = 50��60��...��150),12 �� 22 ��Ϊ femtomatching����(N = 50��60��...��150),23 �� 33 ��Ϊ RAT ����(N = 50��60��
...��150)��
3. ÿ�����ݵĸ�ʽΪ:
    lost(1),rate(2),fairness(3),average_cascade_per_loop(4),average_cascade_per_chain(5),average_cascade_per_comer(6)