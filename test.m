samples = 60;
chains  =  4;
figname = 'test';

plot(randn(samples, chains));

print(gcf, '-depsc', '-loose', figname)

str.figname = figname;
str.samples = samples;
str.chains  = chains;

str2tex(struct('chains', chains, 'samples', samples, 'fig1', figname), ...
    'mldat', 'mlg')