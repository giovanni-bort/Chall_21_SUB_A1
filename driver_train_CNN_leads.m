%function driver_train_CNN_leads    Challenge-2021
%  n_files_max : numero massimo di files da esaminare
%  opt_CNN  1:GoogleNet   2:Squizenet
%  opt_IMG_DB  or dir_CINC_DL_IMG
% 
% 
ord_classes=[];k=0;      % odrinal classes : numerazione classes da 1 a 28.
opt_IMG_DB=0;


 for i=[1:4 6:23 25:26],k=k+1;ord_classes{k}=num2str(i,'%02.0f');end
% for i=1:28,classes{i}=num2str(i,'%02.0f');end

opt_PRN=0;
%opt_CHALL_leads=12;

  opt_NFold=1;
  maxEpochs=2;
  opt_resume=1;
  file_resume= 'NEW_NET_12L.mat';
dir_CINC_DL_IMG=output_directory;


code_CH_leads='12L'; % OTHERWISE n=12
if(opt_CHALL_leads==2 ),code_CH_leads='02L';end
if(opt_CHALL_leads==3 ),code_CH_leads='03L';end
if(opt_CHALL_leads==6 ),code_CH_leads='06L';end
if(opt_CHALL_leads==12),code_CH_leads='12L';end
fprintf('Code Challenge Leads: %s --\n',code_CH_leads);
DIR_leads=['ECG_' code_CH_leads];





NORM_chk=1;


  n_MAX_rec=400;
  while n_MAX_rec>0
    [list_ok, files_ok, full_files_ok ,List_Diagn_ok]=select_train_rec_leads(dir_CINC_DL_IMG,DIR_leads,n_MAX_rec,0,NORM_chk);
    n_MAX_rec=0;
  end
  
fprintf(' numero records:%6.0f\n',numel(files_ok));
N_fold=opt_NFold;
%allImages = imageDatastore(dir_CINC_DL_IMG ) ;
allImages = imageDatastore(full_files_ok ) ;
n_files=numel(allImages.Files);
IND_FILES=1:n_files;
fprintf('initial image_datastore(%s), %6.0f files\n',dir_CINC_DL_IMG,n_files);
fprintf('initial image_datastore(%s), %6.0f files\n',dir_CINC_DL_IMG,n_files);
ALL_LABELS=[]; Temp_D=0;Temp_D(28)=0;
 for ii=1:n_files
%      ALL_LABELS{ii}=STRUCT(ii).diagn{1};
     ALL_LABELS{ii}=num2str(List_Diagn_ok{ii}(1),'%02.0f');
     Temp_D(List_Diagn_ok{ii}(1))=Temp_D(List_Diagn_ok{ii}(1))+1;
 end
 k2=0;
  for ii=1:n_files                          % add files for multiple diagnoses 
    for kk=2:numel(List_Diagn_ok{ii})
        ALL_LABELS{end+1}=num2str(List_Diagn_ok{ii}(kk),'%02.0f');
        IND_FILES(end+1)=ii;
     Temp_D(List_Diagn_ok{ii}(kk))=Temp_D(List_Diagn_ok{ii}(kk))+1;
        k2=k2+1;
  if((mod(k2,200)==0)&&opt_PRN>0), fprintf(' %6.0f - %6.0f - %6.0f -> %s\n',k2,ii,numel(IND_FILES),ALL_LABELS{end});end
    end
  end
 
  for ijj=1:28
  fprintf('diagn_star %3.0f  n:  %6.0f\n',ijj,Temp_D(ijj))
  end
  
  fprintf('added %4.0f files \n',k2);
  fprintf('ALL_LABELS :%6.0f IND_FILES:%6.0f\n',numel(ALL_LABELS),numel(IND_FILES));

ALL_IMG=imageDatastore(allImages.Files([IND_FILES])); 
ALL_IMG.Labels=categorical(ALL_LABELS);
%allImages.Labels=categorical(ALL_LABELS);

% n_files_max=input(['numero max files  1:' num2str(n_files) '    [' num2str(n_files) ']  ']);
n_files_max=n_files;
if(n_files_max>n_files),n_files_max=n_files;end
clear NET_tot
rng default
% CC = cvpartition(n_files_max,'KFold',N_fold);
n_L1_tot=0;
NET_tot.dir=dir_CINC_DL_IMG;
NET_tot.opt_dir=opt_IMG_DB;
NET_tot.opt_dir=opt_IMG_DB;
NET_tot.opt_NFold=opt_NFold;
NET_tot.n_files_max=n_files_max;
NET_tot.opt_resume=opt_resume;
%---------------------------------------------------------------------------------------
for n_step=1:N_fold
    
%     L_test=find(CC.test(n_step)==1);  N_tst=numel(L_test);
%     L_train=find(CC.test(n_step)==0); N_trn=numel(L_train);
    L_test=IND_FILES(1:20:end);
    L_train=IND_FILES;
N_tst=numel(L_test);
N_trn=numel(L_train);
    fprintf('%4.0f train set: %5.0f  test set:%6.0f\n',n_step,N_trn,N_tst);
    
    L1_tst=ismember(IND_FILES,L_test); L1_ind_tst=find(L1_tst>0);
    L1_trn=ismember(IND_FILES,L_train); L1_ind_trn=find(L1_trn>0);
    n_L1_tot=n_L1_tot+numel(L1_ind_tst);
        fprintf('     train set: %5.0f  test set:%6.0f ->cumulative: %6.0f\n',numel(L1_ind_trn),numel(L1_ind_tst),n_L1_tot);
        
NEW_train=imageDatastore(ALL_IMG.Files([L1_ind_trn]));
NEW_train.Labels=ALL_IMG.Labels([L1_ind_trn]);

NEW_test=imageDatastore(ALL_IMG.Files([L1_ind_tst]));
NEW_test.Labels=ALL_IMG.Labels([L1_ind_tst]);

       [ind_TAB,new_TAB,new_ind]=extend_train(NEW_train.Labels,ord_classes);

       % da aggiunger modifica trainin set 
       if(mod(numel(new_ind),2)==1), new_ind(end+1)=new_ind(end);end

% % %         maxEpochs = 8; % 10; % 30 %15;
% miniBatchSize = 256; maxEpochs = 15; ValidationFrequency=  10;  VerboseFrequency= 50;
% miniBatchSize = 256; maxEpochs = 10; ValidationFrequency=  15;  VerboseFrequency= 50;

       
% [kk1,kk2,kk3 ]=find_multipli(numel(new_ind),26,28);
% [kk1,kk2,kk3 ]=find_multipli(numel(new_ind),30,50);
for KK_STEP=27:100,
   [kk1,kk2,kk3 ]=find_multipli(numel(new_ind),KK_STEP,KK_STEP+10);
   if(kk1>0), break; end
end

       miniBatchSize=kk1; %27
       ValidationFrequency= max(1, fix(kk2/2));
       VerboseFrequency= max(1,fix(kk2/2));
       k_adding=kk3-numel(new_ind);
       new_ind(end+1:end+k_adding)=new_ind(1:k_adding);
fprintf('BatchSize:%5.0f, maxEpochs:%4.0f Val_Freq:%4.0f Verb_freq:%4.0f ',miniBatchSize,maxEpochs,ValidationFrequency,VerboseFrequency);
       fprintf('  total_train:%6.0f (+%3.0f)\n',numel(new_ind),k_adding);
       
 new_ind_sort=sort(new_ind);
TEMP_IMG=imageDatastore(NEW_train.Files([new_ind_sort]));
TEMP_IMG.Labels=NEW_train.Labels([new_ind_sort]);
NEW_train = TEMP_IMG;
 
       
%======================== CNN: GoogleNet =====================================================

% net = googlenet;
% lgraph = layerGraph(net);
% % % % numberOfLayers = numel(lgraph.Layers);
% % % % figure('Units','normalized','Position',[0.1 0.1 0.8 0.8]);
% % % % plot(lgraph)
% % % % title(['GoogLeNet Layer Graph: ',num2str(numberOfLayers),' Layers']);
% 
% % *** Modify GoogLeNet Network Parameters ***
% % To prevent overfitting, a dropout layer is used. A dropout layer randomly sets input elements to zero
% % with a given probability. See dropoutLayer for more information. 
% % The default probability is 0.5. Replace the final dropout layer in the network,
% % 'pool5-drop_7x7_s1', with a dropout layer of probability 0.6.
% newDropoutLayer = dropoutLayer(0.6,'Name','new_Dropout');
% lgraph = replaceLayer(lgraph,'pool5-drop_7x7_s1',newDropoutLayer);
% 
% %  Replace the fully connected layer 'loss3-classifier' with a new fully connected layer with the number 
% % of filters equal to the number of classes. To learn faster in the new layers than in the transferred layers, 
% % increase the learning rate factors of the fully connected layer.
% 
% numClasses = numel(categories(NEW_train.Labels));
% newConnectedLayer = fullyConnectedLayer(numClasses,'Name','new_fc',...
%     'WeightLearnRateFactor',5,'BiasLearnRateFactor',5);
% lgraph = replaceLayer(lgraph,'loss3-classifier',newConnectedLayer);
% 
% % The classification layer specifies the output classes of the network. 
% % Replace the classification layer with a new one without class labels. 
% % trainNetwork automatically sets the output classes of the layer at training time.
% newClassLayer = classificationLayer('Name','new_classoutput');
% lgraph = replaceLayer(lgraph,'output',newClassLayer);



if (opt_CHALL_leads==12), load ( 'NEW_NET_12L.mat'); end    % save NEW_NET_12L  'NEW_NET_1'   **** salvataggio *****
if (opt_CHALL_leads==6 ), load ( 'NEW_NET_06L.mat'); end
if (opt_CHALL_leads==3 ), load ( 'NEW_NET_03L.mat'); end
if (opt_CHALL_leads==2 ), load ( 'NEW_NET_02L.mat'); end


% *****  Set Training Options and Train GoogLeNet *******
% Set the random seed to the default value.
%  maxEpochs = 15;
% miniBatchSize = 256; maxEpochs = 15; ValidationFrequency=  10;  VerboseFrequency= 50;
% miniBatchSize = 256; maxEpochs = 10; ValidationFrequency=  15;  VerboseFrequency= 50;
%miniBatchSize =  10; maxEpochs =  8; ValidationFrequency= 250;  VerboseFrequency=125;

options = trainingOptions('sgdm',...
    'MiniBatchSize',miniBatchSize,...
    'MaxEpochs',maxEpochs,...
    'InitialLearnRate',1e-4,...
    'ValidationData',NEW_test,...
    'ValidationFrequency',ValidationFrequency,...
    'Verbose',1,...
    'VerboseFrequency',VerboseFrequency, ...
    'ExecutionEnvironment','cpu');
%     'CheckpointPath',DIR_check_points,...
%     'Plots',opt_PLOTS_NN);
%     'CheckpointPath','DIR_CHECKS',...
rng default
fprintf('Train Network: miniBatchSize:%5.0f, maxEpochs:%4.0f Val_Freq:%4.0f Verb_freq:%4.0f\n',miniBatchSize,maxEpochs,ValidationFrequency,VerboseFrequency);
% Train the network. The training process usually takes 1-5 minutes on a desktop CPU. 
% The command window displays training information during the run. 
% Results include epoch number, iteration number, time elapsed, mini-batch accuracy, 
%validation accuracy, and loss function value for the validation data.
% --------   to resume a trained CNN, insert : layerGraph(net)

if(opt_resume==0), trainedGN = trainNetwork(NEW_train,lgraph,options); end                               % new training
% if(opt_resume==1), trainedGN = trainNetwork(NEW_train,layerGraph(AA.NET_tot.CNN(n_step).net),options);  end  % resume old CNN
if(opt_resume==1), trainedGN = trainNetwork(NEW_train,layerGraph(NEW_NET_1),options);  end  % resume old CNN

% Inspect the last layer of the trained network. Confirm the Classification Output layer includes the three classes.
trainedGN.Layers(end)

% Evaluate the network using the validation data.
[YPred,probs] = classify(trainedGN,NEW_test);
[YTrain,probs1] = classify(trainedGN,NEW_train);
accuracy = mean(YPred==NEW_test.Labels);
disp(['GoogleNet Accuracy: ',num2str(100*accuracy),'%']);

[TAB_val,TAB_trn]=check_accuracy(NEW_test.Labels,YPred,ord_classes,NEW_train.Labels,YTrain);

NET_tot.CNN(n_step).net=trainedGN;
NET_tot.CNN(n_step).train=NEW_train;
NET_tot.CNN(n_step).test=NEW_test;
NET_tot.CNN(n_step).miniBatchSize=miniBatchSize;
NET_tot.CNN(n_step).maxEpochs = maxEpochs;
NET_tot.CNN(n_step).ValidationFrequency = ValidationFrequency;
NET_tot.miniBatchSize=miniBatchSize;
NET_tot.maxEpochs = maxEpochs;
NET_tot.ValidationFrequency = ValidationFrequency;
NET_tot.typeNN='googlenet';

if(n_step==1)
    TAB_val_T=TAB_val; TAB_trn_T=TAB_trn;
else
    TAB_val_T=TAB_val_T+TAB_val; TAB_trn_T=TAB_trn_T+TAB_trn;
end
%=============================================================================

end


%Net_Name=['NET_tot_I' num2str(opt_IMG_DB) 'F' num2str(N_fold)  datestr(now,'_mm_dd_HH_MM')];
Net_Name=['NET_' code_CH_leads '_I' num2str(opt_IMG_DB) 'F' num2str(N_fold)  datestr(now,'_mm_dd_HH_MM')];

%save (Net_Name, 'NET_tot');

 fprintf('saved in file: %s\n', Net_Name);

print_accuracy(TAB_val_T,TAB_trn_T,ord_classes);

    