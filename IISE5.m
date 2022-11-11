lc0=lc0*mpc0.baseMVA;
lc1=lc1*mpc0.baseMVA;
lc2=lc2*mpc0.baseMVA;
lc3=lc3*mpc0.baseMVA;
lc4=lc4*mpc0.baseMVA;
lc5=lc5*mpc0.baseMVA;

lc1(lc1<0.01) = 0;
lc2(lc2<0.01) = 0;
lc3(lc3<0.01) = 0;
lc4(lc4<0.01) = 0;
lc5(lc5<0.01) = 0;

LC1=sum(CtgList{1}(:,2).*lc1,1);
LC2=sum(CtgList{2}(:,3).*lc2,1);
LC3=sum(CtgList{3}(:,4).*lc3,1);
LC4=sum(CtgList{4}(:,5).*lc4,1);
LC5=sum(CtgList{5}(:,6).*lc5,1);
LC=lc0+LC1+LC2+LC3+LC4+LC5;  %lc0 不应该乘正常状态的概率吗

IISELC1 = sum(CtgList{1}(:,3).*lc1,1);
IISELC2 = 0;
parfor i = 1 : size(lc2,1)
    LCtmp = lc2(i);
    LCtmp = LCtmp - lc1(CtgList{2}(i,1))- lc1(CtgList{2}(i,2));
    IISELC2 = IISELC2 + CtgList{2}(i,4).*LCtmp;
end

IISELC3 = 0;
parfor i = 1 : size(lc3,1)
    LCtmp = lc3(i);
    Ctg = CtgList{3}(i,1:3);
    Ctg2 = nchoosek(Ctg,2);
    for j = 1 : size(Ctg2,1)
        tmp = find(CtgList{2}(:,1)==Ctg2(j,1));
        a = tmp(1);
        t = a + Ctg2(j,2) - Ctg2(j,1)-1;
        LCtmp = LCtmp - lc2(t);
    end
     LCtmp = LCtmp + lc1(CtgList{3}(i,1))+ lc1(CtgList{3}(i,2)) + lc1(CtgList{3}(i,3));
    IISELC3 = IISELC3 + CtgList{3}(i,5).*LCtmp; 
end
IISELC4 = 0;
parfor i = 1 : size(lc4,1)
    LCtmp = lc4(i);
    Ctg = CtgList{4}(i,1:4);
    Ctg2 = nchoosek(Ctg,2);
    for j = 1 : size(Ctg2,1)
        tmp = find(CtgList{2}(:,1)==Ctg2(j,1));
        a = tmp(1);
        t = a + Ctg2(j,2) - Ctg2(j,1)-1;
        LCtmp = LCtmp + lc2(t);
    end
    Ctg3 = nchoosek(Ctg,3);
    for j = 1 : size(Ctg3,1)
        tmp = find(CtgList{3}(:,1)==Ctg3(j,1));
        a = tmp(1);
        tmp = find(CtgList{3}(tmp(1):tmp(end),2)==Ctg3(j,2));
        a = a + tmp(1) -1;
        t = a + Ctg3(j,3) - Ctg3(j,2)-1;
        LCtmp = LCtmp - lc3(t);
    end
    Lctmp = LCtmp - lc1(CtgList{4}(i,1)) - lc1(CtgList{4}(i,2)) - lc1(CtgList{4}(i,3)) - lc1(CtgList{4}(i,4));
    IISELC4 = IISELC4 + CtgList{4}(i,6).*LCtmp;
end

IISELC5 = 0;
for i = 1 : size(lc5,1)
    LCtmp = lc5(i);
    Ctg = CtgList{5}(i,1:5);
    Ctg2 = nchoosek(Ctg,2);
    for j = 1 : size(Ctg2,1)
        tmp = find(CtgList{2}(:,1)==Ctg2(j,1));
        a = tmp(1);
        t = a + Ctg2(j,2) - Ctg2(j,1)-1;
        LCtmp = LCtmp - lc2(t);
    end
    Ctg3 = nchoosek(Ctg,3);
    for j = 1 : size(Ctg3,1)
        tmp = find(CtgList{3}(:,1)==Ctg3(j,1));
        a = tmp(1);
        tmp = find(CtgList{3}(tmp(1):tmp(end),2)==Ctg3(j,2));
        a = a + tmp(1) -1;
        t = a + Ctg3(j,3) - Ctg3(j,2)-1;
        LCtmp = LCtmp + lc3(t);
    end
    Ctg4 = nchoosek(Ctg,4);
    for j = 1 : size(Ctg4,1)
        tmp = find(CtgList{4}(:,1)==Ctg4(j,1));
        a = tmp(1);
        tmp = find(CtgList{4}(tmp(1):tmp(end),2)==Ctg4(j,2));
        a = a + tmp(1) -1;
        tmp = find(CtgList{4}(a:a+tmp(end)-tmp(1),3)==Ctg4(j,3));
        a = a + tmp(1) -1;   %------------------
        t = a + Ctg4(j,4) - Ctg4(j,3)-1;
        LCtmp = LCtmp - lc4(t);
    end
%     if Ctg == [1,2,3,5,6]
%         kkk =1 ;
%     end
    Lctmp = LCtmp + lc1(CtgList{5}(i,1)) + lc1(CtgList{5}(i,2)) + lc1(CtgList{5}(i,3)) + lc1(CtgList{5}(i,4))+ lc1(CtgList{5}(i,5));
    IISELC5 = IISELC5 + CtgList{5}(i,7).*LCtmp;
end

IISELC =  IISELC1 + IISELC2 + IISELC3 + IISELC4 + IISELC5
