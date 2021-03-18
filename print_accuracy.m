function print_accuracy(TAB_val_T,TAB_trn_T,classes);

fprintf('------ summary -----\n');
fprintf('  Classes  ( ------Training set------)    ---------Validation set-------\n');
for ij=1:numel(classes)
fprintf('%2.0f',ij);  fprintf(' %15s ',classes{ij});

fprintf(' (%4.0f:%6.0f /%4.0f ',TAB_trn_T(ij,1:3));
if(TAB_trn_T(ij,3)>0),fprintf('%6.1f%%)',100*TAB_trn_T(ij,2)/TAB_trn_T(ij,3)); else fprintf('  ----%%)');end

fprintf('%10.0f:%6.0f /%4.0f ',TAB_val_T(ij,1:3));
if(TAB_val_T(ij,3)>0), fprintf('%6.1f%%',100*TAB_val_T(ij,2)/TAB_val_T(ij,3));else fprintf('  ----%%');end
fprintf('\n');
end
sum_trn=sum(TAB_trn_T(:,3));
sum_val=sum(TAB_val_T(:,3));
mean_trn=nanmean(TAB_trn_T(:,2)./TAB_trn_T(:,3))*100;
mean_val=nanmean(TAB_val_T(:,2)./TAB_val_T(:,3))*100;

fprintf('%29.0f%7.1f%% %23.0f%7.1f%%\n',sum_trn,mean_trn,sum_val,mean_val);

end
