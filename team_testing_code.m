% % Apply classifier model to test set

function [score, label,classes] = team_testing_code(data,header_data, loaded_model)

[recording,Total_time,Max_leads,Fs] = extract_data_from_header(header_data);

n_samples=size(data,2);

ECG=zeros(12,n_samples);

if(Max_leads==12),
    ECG=data;
end
if(Max_leads==6),
    ECG([1:6],:)=data;
end
if(Max_leads==3),
    ECG([1 2 8],:)=data;
end
if(Max_leads==2),
    ECG([2 11],:)=data;
end

model   = loaded_model.model;
classes = loaded_model.classes;

num_classes = length(classes);

label = zeros([1,num_classes]);

score = ones([1,num_classes]);

% Extract features from test data
tmp_hea = strsplit(header_data{1},' ');
num_leads = str2num(tmp_hea{2});
[leads, leads_idx] = get_leads(header_data,num_leads);




fprintf('ECG:%2.0f%6.0f  ',size(data));
fprintf('n_leads:%3.0f  ',num_leads);
fprintf('idx:');fprintf('%3.0f',leads_idx{:});
fprintf(' Model:%3.0f Fs:%4.0f',model.num_leads,Fs);
fprintf('\n');

H_Fs=Fs;

last_ECG_preproc;     %filtri vari su ECG

valuta_Leads_Trained_NN;       %==> calcola my_label e my_scores

%------------------------------

    DIAGN_star=[270492004 	164889003 	164890007 	426627000 	713427006 	713426002 	445118002   39732003 	164909002 ...
            251146004 	698252002 	10370003 	284470004 	427172004  164947007 	111975006 	164917005 	47665007  ...
            59118001 	427393009 	426177001   426783006 	427084000 	63593006 	164934002 	59931005 	17338001 9999999 ];
classes_dbl=0;
    for i_cl=1:numel(classes)
       classes_dbl(i_cl)=str2double(classes{i_cl});
    end
[IC1,IC2,IC3]=intersect(classes_dbl,DIAGN_star);

my_label_ext=0; my_label_ext(28)=0;
my_scores_ext=0; my_scores_ext(28)=0;
my_label_ext([1:4 6:23 25:26])=my_label;
my_scores_ext([1:4 6:23 25:26])=my_scores;

%  for i=[1:4 6:23 25:26],k=k+1;classes_star{k}=num2str(i,'%02.0f');end
fprintf('label:');fprintf('%6.1f',my_label);fprintf('\n');
fprintf('labEX:');fprintf('%6.1f',my_label_ext);fprintf('\n');
fprintf('score:');fprintf('%6.3f',my_scores);fprintf('\n');
fprintf('scoEX:');fprintf('%6.3f',my_scores_ext);fprintf('\n');


out_labels=0;out_labels(1:numel(classes))=0;
scores=0;    scores(1:numel(classes))=0;
if(numel(IC1)>0)
  out_labels(IC2)=my_label_ext(IC3);
  scores(IC2)  = my_scores_ext(IC3);
else
    fprintf('***** non common labels ***** classes: %6.0f\n',numel(classes));
end
    
%------------------------------

fprintf('o_sco:');fprintf('%5.2f',scores);fprintf('\n');
fprintf('o_lab:');fprintf('%5.2f',out_labels);fprintf('\n');



% Use your classifier here to obtain a label and score for each class.
%score = mnrval(model,features);
[~,idx] = nanmax (score);

label(idx)=1;
n_classes=numel(classes);
fprintf('numero classi: %6.0f\n',n_classes);
score(n_classes)=0;
label(n_classes)=0;
score=scores;
label=out_labels;
end
