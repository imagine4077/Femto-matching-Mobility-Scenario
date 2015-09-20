README
================

#### Profile

Femto-matching is a offloading algorithm that proposed by Pro. Wei Wang et al.(NJU)

#### Reference

**Wang W, Wu X, Xie L, et al. Femto-matching: Efficient traffic offloading in heterogeneous cellular networks[C]//Computer Communications (INFOCOM), 2015 IEEE Conference on. IEEE, 2015: 325-333.**


#### 一、概述

1. 做了三种折扣情况的实验,分别是 3 折、5 折和不打折。

2. 对于每种折扣:LOOP = 1000,即对于每种折扣,分别做 1000 次独立互不相关实验。

3. 对于每次“独立互不相关”实验:包含 11 组实验,即 femtocell 分别为 50、60...150 的11 组实验。femtocell = 50 时,随机得到 femtocell 位置集 和 user 位置集,分别设为 femto_set和 user_set 。femtocell = 60 时,再 femtocell = 50 的 femto_set 和 user_set 基础上再随机洒落 10个 femtocell 以及 50(或 60)个user。femtocell = 50 时的用户保持原有的初始位置和移动方式。

4. 对于每组实验(即某一 femtocell 密度下的实验):numloop = 300,即每个用户共移动300 步。用户每移动一步,算法就做一次检查。三种算法的检测方法见下文。

#### 二、College

**(一)策略描述:**

1. 每移动一步,查看系统中各用户情况,选出如下情况用户:

		a. 无连接用户
		b. 走出原基站覆盖范围的用户

将此两类用户存入“待处理用户集”(代码中命名为 moved_point)。

2. 对于“待处理用户集”中的用户:

    (a)搜集其希望接入的 BS(选择距离自身最近的基站)。
    (b)若此基站未满额,则直接接入,并将此用户移出“待处理用户集”;
    (c)若满额,则与已接入的 quota(即额定收容用户个数)个用户对比:
    (c-1)若其距离能排入前 quota 名,则接入,并踢出距离最大的用户,被踢出用户被加入“待处理用户集”中,并将此用户移出“待处理用户集”。
    (d-2)若距离没能排进前 quota 名,则将此用户与此基站的距离设为 inf。

3. 执行步骤 2 直至收敛(即连接拓扑不再变化,且无任何用户将自身与 BS 距离设为 inf)。

#### 三、RAT-game

**(一)策略描述:**

1. 每移动一步,查看系统中各用户情况,选出如下情况用户:

    (a)无连接用户
    (b)走出原基站覆盖范围的用户

2. 将此两类用户存入“待处理用户集”(代码中命名为 moved_point)。2、对于“待处理用户集”中的用户:

    (a)通过距离计算各用户与各 BS 的 rate。
    (b)搜集其希望接入的 BS(根据接入各个基站所能获得的 rate 的评估,选择估值最高的 BS)。
    (c)若此基站未满额,则直接接入;
    (d)若满额,则与已接入的 quota(即额定收容用户个数)个用户对比:
        (d-1)若 rate 能排进前 quota 名,则接入,并踢出 rate 最低的用户,被踢出用户被加入“待处理用户集”中。
        (d-2)若 rate 没能排进前 quota 名,则将此用户与此基站的距离设为 inf。

3. 执行步骤 2 直至收敛(即连接拓扑不再变化,且无任何用户将自身与 BS 距离设为 inf)。

**(二)细节:**

1. 与 college 的一个区别是,当前用户(设称之为 U1),若 U1 获得连接权,college 会将U1 移出“待处理用户集”;而 RAT-game 仍将 U1 保留在“待处理用户集”。如此设计的原因是:考虑到 RAT-game 非移动版本的算法中,用户动态地选择最优的基站(例如 U1 接入某基站后 U2 也接入了此基站,此时 U1 可分得的 rate 低于预期,而此时又发现有更好的基站,则 U1 选择接入更好的)。与非 mobile 版本算法的区别是:

    (a)非移动版本中,若某基站满额,则不考虑此基站;移动版本中,即使“wanted_BS”满额,仍会考虑接入。
    (b)非移动版本中,每个用户都在不停寻找更优基站;移动版本中,只有“待处理用户集”中的用户寻找更优基站(即用户 U1 接入时,在接入的极短暂时间区间内会环顾四周寻求更优,在确定接入后不再主动切换基站)。

#### 四、Femto-matching

**(一)策略描述:**

1. 每移动一步,查看系统中各用户情况,选出如下情况用户:

    (a)无连接用户
    (b)走出原基站覆盖范围的用户

将此两类用户存入“待处理用户集”(代码中命名为 moved_point)。对于“走出原基站覆盖范围的用户”,将其原连接 VBS 的 price 下调至初始状态( -w*log2(( i-1)^(i-1)/i^i))

2. 记录此时的拓扑(assignment),记为“ori_ass”

3. 对于“待处理用户集”中的用户:

    (a)计算各 BS 对于此用户(以 U1 为例)的 margin,若 ori_ass(U1)不为零(即无连接),则 ori_ass(U1)对 U1 打折。代码表示:
	margin=lograte(:,U1)-curprice;
	if ori_ass(U1) ~= 0 %若之前有连接,则在原连接基站享受打折
		margin(ori_ass(U1))=lograte(ori_ass(U1),U1)-discount*curprice(ori_ass(U1));
	end
    (b)用户搜集其 margin 最高的 BS,和次高的 BS。若最高 margin 小于等于 0,则此用户无法连接。
    (c)若最高 margin 大于 0,则对最高 margin 对应的 BS 提出 bid,BS 选择 bid 最高的用户接入对应的 VBS,并将此 VBS 的价格提高 bid 。
    (d)将已建立连接的用户移出“待处理用户集”,若步骤 c 中所述 VBS 原本有用户占有,步骤 c 导致原占有者被踢出,则被踢出的用户被加入至“待处理用户集”。

4. 执行步骤 3 直至收敛(即连接拓扑不再变化)。

#### 五、数据格式

1. 每 33 行为一组,每组以’\n’分隔。
2. 每组 1 至 11 行为 college 数据(N = 50、60、...、150),12 至 22 行为 femtomatching数据(N = 50、60、...、150),23 至 33 行为 RAT 数据(N = 50、60、
...、150)。
3. 每行数据的格式为:

    lost(1),rate(2),fairness(3),average_cascade_per_loop(4),average_cascade_per_chain(5),average_cascade_per_comer(6)

