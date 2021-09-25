PAPERS: 

The following two papers are relevant. Manski was the first to recognize the reflection problem. Leary/Roberts are the first to propose to use idiosyncratic equity shocks obtained from asset pricing models to construct peer shocks to identify peer effects. (You can also use my data to replicate Leary/Roberts.)


https://academic.oup.com/restud/article-abstract/60/3/531/1570385

https://onlinelibrary.wiley.com/doi/full/10.1111/jofi.12094


DATA:

For each permno and year, I have provided firm-specific shocks based on the CAPM as well as Fama-French 3- and 5-factor models.

You can construct peer shocks for each SIC x-digit level, depending on your research context, by adding the firm-specific shocks for each permno i in industry j without that of i in year t. This is your UnIV for industry j in year t.

I have done this for SIC 3-digit industries. See file PeerShocks.csv


REGRESSIONS:

Your model would typically be as follows:

Y = Y.avg + X + X.avg + Industry fixed effects 

Y and X refer to permno i und Y.avg and X.avg refer to the average of peer group of i. 

2SLS: You instrument Y.avg with the peer shock, i.e., the UnIV.  This should identify the causal peer effect (given that the first stage is significant).
