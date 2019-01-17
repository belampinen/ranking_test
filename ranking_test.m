function p = ranking_test(vals, do_plot)
%
% The input 'vals' is an N x M x L matrix with numerical observations yielded
% by different methods (N) for different categories (M)
% across repeated measurements (L)
%
% The function calculates a p-value for the null hypothesis that the mean
% values yielded by the different methods correspond to the same ranking
% of categories
%

if (nargin < 2), do_plot = 1; end
%
if (nargin < 1)
    data_fn     = fullfile(pwd, 'example_data.mat');
    tmp         = load(data_fn);
    vals        = tmp.vals;        % size = n_method x n_category x n_measurement
end

% Obtain means and standard deviations across measurements
vals_m      = mean(vals, 3);
vals_std    = std(vals, 0, 3) / sqrt(size(vals, 3));

% Observed ranking of categories by means
[vals_m_sorted, i0] = sort(vals_m, 2, 'descend');
r_obs               = zeros(size(i0));
for c = 1:size(i0,1), r_obs(c, i0(c,:)) = 1:size(i0,2); end

% Observed statistic
m_obs     = ranks2m(r_obs);

% Pre-sort means and standard deviations
vals_m      = vals_m_sorted;
for c = 1:size(i0,1)
    vals_std(c,:) = vals_std(c, i0(c,:));
end

% Obtain distribution of the statistic expected under random rankings
n_set     = 1e5;
m_dist    = zeros(n_set, 1);
%
for c_set = 1:n_set
    
    % Noise the pre-sorted mean values
    vals_m_c = vals_m + 1.0 * randn(size(vals_m)) .* vals_std;
    
    % Rank the noised mean values
    [~, i] = sort(vals_m_c, 2, 'descend');
    r_c    = zeros(size(i));
    for c = 1:size(i,1), r_c(c, i(c,:)) = 1:size(i,2); end
    
    % Metric for the rank
    m_dist(c_set) = ranks2m(r_c);
end

% Calculate p-value
p = mean(m_obs <= m_dist);

% Present results
if  (do_plot)
    figure(364)
    clf
    set(gcf, 'color', 'w')
    %
    histogram(m_dist, 'facecolor', 'k') % , 'color', 'k')
    hold on
    plot(repmat(m_obs, 100), linspace(0, max(get(gca, 'ylim')), 100), ...
        '--r', 'linewidth', 2);
    set(gca, 'box', 'off', 'tickdir', 'out', 'ytick', [], 'linewidth', 2, ...
        'fontsize', 14)
    xlabel('Metric value')
    ylabel('Frequency')
    legend({'Metric distr. (H0)', 'Observed metric'}, 'box', 'off')
    %
    disp(['p-value for observed ranking = ' num2str(p)]);
end
end