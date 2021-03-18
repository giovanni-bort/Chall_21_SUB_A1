function [leads, leads_idx]= get_leads(header_data, num_leads)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Purpose:
% Extract the available ECG leads
% 1. 12 leads are available or
% 2. 6 leads are available: I, II, III, aVR, aVL & aVF or
% 3. 3 leads are avialable: I, II & V2 or
% 4. 2 leads are avialable: I & V5

% Inputs:
% 1. Header files and the number of leads 
%
% Outputs:
% leads: available leads names
% leads_idx: The index of available leads 
%
% Author: Nadi Sadr, PhD, <nadi.sadr@dbmi.emory.edu>
% Version 1.0
% Date 9-Dec-2020
% Version 2.0 26-Jan-2021
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Define 12, 6, and 2 lead ECG sets.
twelve_leads = ['I', 'II', 'III', 'aVR', 'aVL', 'aVF', 'V1', 'V2', 'V3', 'V4', 'V5', 'V6'];
six_leads    = ['I', 'II', 'III', 'aVR', 'aVL', 'aVF'];
three_leads  = ['I', 'II', 'V2'];
two_leads    = ['II', 'V5'];

leads = {};
jj =1;
tmp_hea = strsplit(header_data{1},' ');
[recording,Total_time,Max_leads] = extract_data_from_header(header_data);


% Extract 12 leads
if num_leads==12
    for ii=1:Max_leads
        tmp_hea   = strsplit(header_data{ii+1},' ');
        leads{ii} = tmp_hea{9};
        leads_idx{ii} = ii;
    end
% Extract 6 leads
elseif num_leads==6    
    for ii=1:Max_leads
        tmp_hea   = strsplit(header_data{ii+1},' ');
        Lead_name{ii} = tmp_hea{9};
        switch Lead_name{ii}
            case 'I'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'II'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'III'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'aVR'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'aVL'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'aVF'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
        end
    end 
    
% Extract 3 leads    
elseif num_leads==3
    for ii=1:Max_leads
        tmp_hea   = strsplit(header_data{ii+1},' ');
        Lead_name{ii} = tmp_hea{9};
        switch Lead_name{ii}
            case 'I'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'II'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'V2'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
        end
    end
    
% Extract 2 leads    
elseif num_leads==2
    for ii=1:Max_leads
        tmp_hea   = strsplit(header_data{ii+1},' ');
        Lead_name{ii} = tmp_hea{9};
        switch Lead_name{ii}
            case 'II'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
            case 'V5'
                leads_idx{jj} = ii;
                leads{jj}  = Lead_name{ii};
                jj = jj+1;
        end
    end
    
end

end


