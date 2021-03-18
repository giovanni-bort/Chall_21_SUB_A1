function [new_name,k_type,k_num,name_header_or,name_header]=extract_info_from_name(name)
K=0;if(name(1:4)=='ECG_'),name=name(5:end);end
k_num=0;
   if(name(1)=='A'),k_type='A';k_num=sscanf(name(2:end),'%f');K=K+1;end
   if(name(1)=='Q'),k_type='Q';k_num=sscanf(name(2:end),'%f');K=K+1;end
   if(name(1)=='E'),k_type='E';k_num=sscanf(name(2:end),'%f');K=K+1;end
   if(name(1)=='I'),k_type='I';k_num=sscanf(name(2:end),'%f');K=K+1;end
   if(name(1)=='S'),k_type='S';k_num=sscanf(name(2:end),'%f');K=K+1;end
   if(name(1)=='H')
       k_type='H';
       if(name(2:2)=='R'), k_num=sscanf(name(3:end),'%f');K=K+1;
       else  k_num=sscanf(name(2:end),'%f');K=K+1;
       end
   end
   
   if(k_num==0),fprintf('****error: name:%s\n',name);end
   new_name=sprintf('%s%05.0f',k_type,k_num);
%    fprintf('num-->%s\n',name(2:end));
%    fprintf('key: %s   num=%6.0f\n',k_type,k_num);
name_header_or='';
if(name(1)=='A'),name_header_or=['A'  num2str(k_num,'%04.0f'), '.hea'];end
if(name(1)=='Q'),name_header_or=['Q'  num2str(k_num,'%04.0f'), '.hea'];end
if(name(1)=='E'),name_header_or=['E'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='I'),name_header_or=['I'  num2str(k_num,'%04.0f'), '.hea'];end
if(name(1)=='S'),name_header_or=['S'  num2str(k_num,'%04.0f'), '.hea'];end
if(name(1)=='H'),name_header_or=['HR' num2str(k_num,'%05.0f'), '.hea'];end

name_header='';
if(name(1)=='A'),name_header=['A'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='Q'),name_header=['Q'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='E'),name_header=['E'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='I'),name_header=['I'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='S'),name_header=['S'  num2str(k_num,'%05.0f'), '.hea'];end
if(name(1)=='H'),name_header=['H'  num2str(k_num,'%05.0f'), '.hea'];end

end


   
   