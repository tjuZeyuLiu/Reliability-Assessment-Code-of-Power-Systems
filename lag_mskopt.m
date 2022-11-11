function [plc,xb]=lag_mskopt(a,b,c,o)
prob.a=a;
prob.c=c';
prob.blc=b;
prob.buc=b;
prob.blx=zeros(size(c,2),1);
prob.bux=[];
cmd='minimize echo(0)';
mosek_opt.MSK_IPAR_NUM_THREADS = 1;
[~,res]=mosekopt(cmd,prob,mosek_opt);
plc=res.sol.bas.pobjval;
xb=find(res.sol.bas.skx(:,1)=='B');
cb=find(res.sol.bas.skc(:,1)=='B');
if ~isempty(cb)
   xb=[xb;cb+o];
end
%     sp.xb = xb;
%     sp.BB =a(:,xb);
%     sp.w = c(xb)/ sp.BB;
      
% judge=find((xb>o&xb<=2*o)|xb>3*o+p);
% % judge=(xb>o&xb<=2*o)|xb>3*o+p;
% B = a(:,xb);
% invB=inv(a(:,xb));
% sp.invB=invB(judge,:);
% sp.w=c(xb)*invB;