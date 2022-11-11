clear;
mpc0=load('case24');
mpc0=mpc0.mpc;

ldlv=load('ld1_lv8760');
ldlv=ldlv.ldlv;

CtgLevelMax = 4;
[ CtgList, CpntList ] = CreatSECtgList(mpc0, CtgLevelMax);

GenBrU = CtgList{1}(:,3);
GenBrA = 1 - GenBrU;
BrNum = size(mpc0.branch(:,1),1);
GenNum = size(mpc0.gen(:,1),1);
McsNum = 10000000;

LC=zeros(McsNum,1);
tic;
for i=1:McsNum

        mpc=mpc0;
        GenBrRand = rand(GenNum+BrNum-1,1);
        GenBrS = GenBrRand < GenBrU;
        ll = ldlv(unidrnd(8760),1);
        CtgCpntList = CpntList(GenBrS, :);
        CtgGenList = (1 == CtgCpntList(:, 1));
        CtgBrList = (2 == CtgCpntList(:, 1));
        mpc.gen(CtgCpntList(CtgGenList, 2),:) = [];
        mpc.branch(CtgCpntList(CtgBrList, 2), :) = [];
        LC(i)=mcs_ld1_cal(mpc,ll);
      if mod(i,1000000) == 0
       disp(i);
      end
end

time=toc
EENS = sum(LC)*8760/McsNum*mpc0.baseMVA

savestr=strcat('MCS_ld1_cs24.mat');
save(savestr,'EENS','LC','time');