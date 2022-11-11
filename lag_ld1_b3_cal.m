  function [lc,xbb,invBB1,num,lagnum,n,k]=lag_ld1_b3_cal(mpc,ldlv,A,b,c,xbb,invBB,delg)
       lagnum = 0;                            %记录用了几次优化包直接求解
       num =1;                                % num=1代表第一个拓扑匹配失败，外层spnum+1；
       o=size(mpc.bus,1);
       p=size(mpc.gen,1);
       q=size(mpc.branch,1);
       ldlvnum=size(ldlv,1);
        b(delg+2*o) = 0;                         %发电机出力设置为0

    %% Core Part
        lc = 0;
        sp.invB = 0;
        sp.w = 0;
for ldi = 1 : ldlvnum
        n = size(xbb,2); %------
        b(mpc.area)=mpc.bus(mpc.area).*ldlv(ldi,1);
        b(o+1:2*o)=b(1:o);     
        k=0;                            %用k记录第几次找到最优基
%---------------------------------------------拓扑分析（第一次）------------------------------------------------------
      if ldi == 1 
          for i = n:-1:1
              if i == n-15                    %限制search次数：15
                  break;
              end  
                  xb = xbb{i};
                  BB = A(:,xb);                                                 %通过xb求得最优基BB，而不是从BC因为A变化了
                  w = c(xb) / BB;                                               %------------耗时严重----------------
              if isnan(w) == 0                                          % w 中无NaN元素
                  if  invBB{i} * b >  -1e-15                
                          k = n - i + 1;                                      % k 记录第几次找到相匹配的最优基位置xb
                          plc = w * b;
                          invBB1 = invBB{i};
                          lc = lc + plc * ldlv(ldi,2);
                          num = 0;                                       %num = 0表示找到最优基
                          xbb = xb;
                          break;                                        %找到即退出循环
                  end
              end
          end
          if  num == 1               %如果第一个负荷下没找到-->常规方法Mosek
                [plc,xb]=lag_mskopt(A,b,c,o);
                lc = lc + plc * ldlv(ldi,2);
                judge = find((xb>o&xb<=2*o)|xb>3*o+p);
                BB = A(:,xb);             
                w = c(xb) / BB;
                xbb = xb;
                invB =  inv(full(BB)); %保留以便后续负荷水平下的计算
                invBB1 = invB(judge,:);
                lagnum = 1;
                n = n + 1;
          end
                spnum = 1;
                sp(spnum).invB = invBB1;
                sp(spnum).w = w; 
%---------------------------------------------时变负荷（第一次之后）--------------------------------------------------
      else                                %第1个负荷水平之后
                flag = 0;
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
                    lagnum = lagnum + 1;
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
                    lc = lc + plc * ldlv(ldi,2);
      end                      
end

