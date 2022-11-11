function []= lag_ld1_main(casenum,ldlvnum)

casenum = 24;                          %选取算例
casenum=num2str(casenum);
casestr=strcat('case',casenum);
mpc0=load(casestr);
mpc0=mpc0.mpc;
warning off all;                        %关闭非奇异矩阵求逆warning

ldlvnum = 10;                            %选取负荷水平
ldlvnum=num2str(ldlvnum);
ldlvstr=strcat('ld1_lv',ldlvnum);
ldlv=load(ldlvstr);
ldlv=ldlv.ldlv;

CtgLevelMax = 5;                        %故障阶数取几阶
[ CtgList, CpntList ] = CreatSECtgList(mpc0, CtgLevelMax); %生成故障列表CtgList

[lc0,AA,bb,cc,xb,spnum0]=lag_ld1_b1_cal(mpc0,ldlv); %正常状态的影响I(s)
lagnum0 = spnum0;

CtgListTmp = CtgList{1};                %一阶故障的影响计算
%————————————存储变量的初始化————————————
lc1=zeros(size(CtgListTmp,1),1);        %影响I(s)
spnum1 = 0;                             %记录第一个负荷水平下常规方法计算的故障数量
lagnum1= zeros(size(CtgListTmp,1),1);  
f1 = zeros(size(CtgListTmp,1),1);        %记录search过程中第几次找到最优基
xbb1{1} = xb;                           %初始化为正常状态s下的xb
tic;                                    %计时开始
for i =1:size(CtgListTmp,1)
       mpc=mpc0;
       CtgCpntNo = CtgListTmp(i,1);       % 故障支路详细列表
       CtgCpntList = CpntList(CtgCpntNo, :);
       CtgGenList = (1 == CtgCpntList(:, 1));
       CtgBrList = (2 == CtgCpntList(:, 1));
    %        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
       mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];   %删除故障线路信息行
       delgen = CtgCpntList(CtgGenList, 2);             %故障发电机编号
       delbr  = CtgCpntList(CtgBrList, 2);              %故障线路编号
       [lc1(i),xb,num,lagnum1(i),n,f1(i)]=lag_ld1_b2_cal(mpc,ldlv,AA,bb,cc,xbb1,delgen,delbr);
        if num == 1    
            spnum1 = spnum1 + num;
            xbb1{n} = xb;
        else
          if f1(i) > 1
            m = n+1-f1(i);
            z = xbb1(m);
            for j = m:n-1
                xbb1(j) = xbb1(j+1);
            end
            xbb1(n) = z;
          end
        end
        if (mod(i,2000)==0)
           disp(i);
        end
end


CtgListTmp = CtgList{2};
lc2=zeros(size(CtgListTmp,1),1);
spnum2 = 0;
lagnum2= zeros(size(CtgListTmp,1),1); 
f2 =zeros(size(CtgListTmp,1),1);
xbb2 = {}; 
xbb2{1} = xb;
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:2);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
      CtgBrList = (2 == CtgCpntList(:, 1));
%        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
        delgen = CtgCpntList(CtgGenList, 2);
        delbr  = CtgCpntList(CtgBrList, 2);
        [lc2(i),xb,num,lagnum2(i),n,f2(i)]=lag_ld1_b2_cal(mpc,ldlv,AA,bb,cc,xbb2,delgen,delbr);
        if num == 1    
            spnum2 = spnum2 + num;
            xbb2{n} = xb;
        else
          if f2(i) > 1
            m = n+1-f2(i);
            z = xbb2(m);
            for j = m:n-1
                xbb2(j) = xbb2(j+1);
            end
            xbb2(n) = z;
          end
        end
    if (mod(i,2000)==0)
       disp(i);
    end
end

CtgListTmp = CtgList{3};
lc3=zeros(size(CtgListTmp,1),1);
spnum3 = 0;
lagnum3= zeros(size(CtgListTmp,1),1); 
f3 =zeros(size(CtgListTmp,1),1);
xbb = {};
invBB = {};
% xbb{1}=xb; 
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:3);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
%       CtgBrList = (2 == CtgCpntList(:, 1));
%        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
%         mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
        delgen = CtgCpntList(CtgGenList, 2);
        [lc3(i),xb,invB,num,lagnum3(i),n,f3(i)]=lag_ld1_b3_cal(mpc,ldlv,AA,bb,cc,xbb,invBB,delgen);
        if num == 1    
            spnum3 = spnum3 + num;  %第一次没找着的
            xbb{n} = xb;
            invBB{n} = invB;
        else
          if f3(i) > 1
            m = n+1-f3(i);
            z = xbb(m);
            zz = invBB(m);
            for j = m:n-1
                xbb(j) = xbb(j+1);
                invBB(j) = invBB(j+1);
            end
            xbb(n) = z;
            invBB(n) = zz;
          end
        end
    if (mod(i,4000)==0)
       disp(i);
    end
end

CtgListTmp = CtgList{4};
lc4=zeros(size(CtgListTmp,1),1);
spnum4 = 0;
lagnum4= zeros(size(CtgListTmp,1),1); 
f4 =zeros(size(CtgListTmp,1),1);
xbb4 = {};
invBB4 = {};
% xbb4{1} = xb;
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:4);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
%       CtgBrList = (2 == CtgCpntList(:, 1));
%        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
%         mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
       delgen = CtgCpntList(CtgGenList, 2);
        [lc4(i),xb,invB,num,lagnum4(i),n,f4(i)]=lag_ld1_b3_cal(mpc,ldlv,AA,bb,cc,xbb4,invBB4,delgen);
        if num == 1    
            spnum4 = spnum4 + num;
            xbb4{n} = xb;
            invBB4{n} = invB;
        else
          if f4(i) > 1
            m = n+1-f4(i);
            z = xbb4(m);
            zz = invBB4(m);
            for j = m:n-1
                xbb4(j) = xbb4(j+1);
                invBB4(j) = invBB4(j+1);
            end
            xbb4(n) = z;
            invBB4(n) = zz;
          end
        end
    if (mod(i,20000)==0)
       disp(i);
    end
end

CtgListTmp = CtgList{5};
lc5=zeros(size(CtgListTmp,1),1);
spnum5 = 0;
lagnum5= zeros(size(CtgListTmp,1),1); 
f5 =zeros(size(CtgListTmp,1),1);
xbb5 = {};
invBB5 = {};
for i =1:size(CtgListTmp,1)
   mpc=mpc0;
     CtgCpntNo = CtgListTmp(i,1:5);       % 故障支路详细列表
     CtgCpntList = CpntList(CtgCpntNo, :);
      CtgGenList = (1 == CtgCpntList(:, 1));
%       CtgBrList = (2 == CtgCpntList(:, 1));
%        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
%         mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
       delgen = CtgCpntList(CtgGenList, 2);
        [lc5(i),xb,invB,num,lagnum5(i),n,f5(i)]=lag_ld1_b3_cal(mpc,ldlv,AA,bb,cc,xbb5,invBB5,delgen);
        if num == 1    
            spnum5 = spnum5 + 1;
            xbb5{n} = xb;
            invBB5{n} = invB;
        else
          if f5(i) > 1
            m = n+1-f5(i);
            z = xbb5(m);
            zz = invBB5(m);
            for j = m:n-1
                xbb5(j) = xbb5(j+1);
                invBB5(j) = invBB5(j+1);
            end
            xbb5(n) = z;
            invBB5(n) = zz;
          end
        end
    if (mod(i,50000)==0)
       disp(i);
    end
end

time = toc
IISE5
spnum = spnum0 + spnum1 + spnum2 + spnum3 + spnum4 + spnum5;         % 拓扑未匹配总数
lagnum_mean = mean([lagnum0;lagnum1;lagnum2;lagnum3;lagnum4;lagnum5]);
lagnum = sum([lagnum0;lagnum1;lagnum2;lagnum3;lagnum4;lagnum5]);    % 所有时变负荷下故障状态计算总数
lagnum11 = sum([lagnum1]);
lagnum22 = sum([lagnum2]);
lagnum33 = sum([lagnum3]);
lagnum44 = sum([lagnum4]);
lagnum55 = sum([lagnum5]);
savestr=strcat('lag_ld1_cs',casenum,'_lv',ldlvnum,'.mat');
save(savestr,'IISELC','IISELC1','IISELC2','IISELC3','IISELC4','IISELC5','lc0','lc1','lc2','lc3','lc4','lc5',...
'LC','LC1','LC2','LC3','LC4','LC5','spnum0','spnum1','spnum2','spnum3','spnum4','spnum5','spnum',...
'lagnum0','lagnum11','lagnum22','lagnum33','lagnum44','lagnum55','lagnum','lagnum_mean','time','lagnum1','lagnum2','lagnum3','lagnum4','lagnum5');

