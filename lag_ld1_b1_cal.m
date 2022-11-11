function [lc,A,b,c,xb,spnum]=lag_ld1_b1_cal(mpc,ldlv)
   o=size(mpc.bus,1);
   p=size(mpc.gen,1);
   q=size(mpc.branch,1);
   ldlvnum=size(ldlv,1);
   B=zeros(o);
   A=sparse(2*o+p+2*q,3*o+2*p+2*q);
  for i=1:q
       B(mpc.branch(i,1),mpc.branch(i,2)) = B(mpc.branch(i,1),mpc.branch(i,2))+ mpc.branch(i,3);
       B(mpc.branch(i,2),mpc.branch(i,1)) =  B(mpc.branch(i,2),mpc.branch(i,1))+ mpc.branch(i,3);
       A(2*o+p+i,mpc.branch(i,1))=mpc.branch(i,3);
       A(2*o+p+i,mpc.branch(i,2))=-mpc.branch(i,3);
   end
   s = -sum(B);
   for i=1:o
       B(i,i)=s(i);
       A(i,i+o)=1;
       A(i+o,i+o)=1;
   end  
   for i=1:p
       A(mpc.gen(i,1),2*o+i)=1;
       A(i+2*o,i+2*o)=1;
   end
   for i=1:o+p+2*q
       A(i+o,i+2*o+p)=1;
   end
   A(1:o,1:o)=-B;
   A(2*o+p+q+1:2*o+p+2*q,1:o)=-A(2*o+p+1:2*o+p+q,1:o);
   b=[zeros(2*o,1);mpc.gen(:,2);mpc.branch(:,4);mpc.branch(:,4)];
   c=[zeros(1,o),ones(1,o),zeros(1,o+2*p+2*q)];
   lc = 0;
   spnum=0;
   for l=1:ldlvnum
      b(mpc.area)=mpc.bus(mpc.area).*ldlv(l,1);
      b(o+1:2*o)=b(1:o);      
     flag=0;
       for i = spnum:-1:max(spnum-1,1)
            if sp(i).invB * b > -1e-8 
                plc = sp(i).w * b;
                flag = 1;
                break;
            end
       end
        if flag == 0
            spnum = spnum + 1;
            [plc,xb] = lag_mskopt(A,b,c,o);   
            invB = inv(full(A(:,xb)));
            judge = find((xb>o&xb<=2*o)|xb>3*o+p);
            sp(spnum).invB = invB(judge,:);
            sp(spnum).w = c(xb) * invB;
        else
            if i ~= spnum 
                sp2 = sp(spnum).invB;
                sp3 = sp(spnum).w;
                sp(spnum).invB = sp(i).invB;
                sp(spnum).w = sp(i).w;
                sp(i).invB = sp2;
                sp(i).w = sp3;
            end
        end
            lc = lc + plc * ldlv(l,2); 
   end