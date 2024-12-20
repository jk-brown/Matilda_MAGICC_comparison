# Matilda v MAGICC7 Comparison
 Comparative analysis between Matilda and MAGICC7 using Ou and Iyer emissions data

Updates and notes:

## 12/06/2024 -- Meeeting with Gokul, Allen, and Ben:

Overall I show that Hector + Matilda does a fairly good job producing a result that largely aligns with MAGICC. However there are some key parts of the Hector + Matilda result that need to be explored further in order to get this in a defensible place. The differences in the output from Hector/Matilda need to be understood so that it can be defended when critiqued.

In the Hector/Matilda probabilistic results from this analysis, Hector produces future projections that are slightly cooler than MAGICC at the end of the century (but not by much). A more pressing concern and interesting finding is the lower uncertainty range, and overall higher likelihood of cooler futures than are projected using MAGICC. These results come from data that are weighted, filtered for top ensemble members, and weighted median and CI are computed (using weights from likelihood comparison against observed criterion). 

These results show that Hector/Matilda significantly reduces the tail risk (at high warming tail). If defensible, this is an important finding and will be of interest to the larger community, could make for a good model comparison documentation paper, and could be informative for IPCC AR7. But, it needs to have a solid defense. So, what more can be done to ensure the Matilda/Hector results are the correct way to go about this and may or may not be a better prediction on future climate chnage compared to MAGICC.

## Experiment proposals and To-Do's:

1. How does the result look for the Hector unconstrained result?
   
   Run hector in an unconstrained framework. How does it compare the the MAGICC result? What should be done with weighting in this type of framework? 

   **1)** Can weight and use the weights for weighted median and CI -- this will probably track the resutls we already have, but with slightly more variability? 

   **2)** Con do a completely unconstrained, unweighted results using Hector/Matilda. This is something I have tried and everything comes in **much** cooler than MAGICC (but WHY!?!). The much cooler response could be due to the parameter set I am using. Any results from Matilda are directly connected to the parameter set that is being used to complete the PPE. So, if the parameters result in significantly cooler projections, then the overall result will be cooler and without wiehgting the overally cool ensmebles in the historical period are not being filtered out.

    If more runs are used, will it allow us to explore the parameter space more extensively, resulting in more warmer projections? Is that what we want? 

    Or is it that the emissions used in this analysis (from Ou and Iyer et al.) inducing a different response in Hector that causes cooler temperatures? If we compare using a generic SSP emissions scenario, how aligned are the probabilistic results? If they are aligned, what is it about these emissions scenarios that causes a different warming response between MAGICC and Hector? could it have something to do with the emissions that are missing from the GCAM output that are specified in the MAGICC analysis?
   
3. Comparing deterministic Hector result (from an Ou and Iyer emissions pathway) with a deterministic MAGICC run.

   Running and comparing deterministic Hector v. MAGICC deterministic (single run for each analysis) will give us another means to compare the differences in the model.

   What would it mean if these results do not match? Based on the probabilistic Hector results already completed, and how it compares to MAGICC, what would be the expectation in single run v. single run analysis?

**To-Do**:
- Complete the simpler experiments
- Better, cleaner visualizations for the experiments. 

## Experiments to think about a little further down the line

 1. Is there a way to ensure that the Hector and MAGICC parameter space is being explored in the same way?
     
    Not sure if this is possible, there is probably (somewhere) documentation of all the parameters that are being sampled in MAGICC -- but not sure how parameters are shared between the two models. They don't seem to have the same GHG emissions (MAGICC has more GHGs). I think they also allow for negative LUC emissions, which Hector does not. 

 2. Is it possible to run Hector in "MAGICC mode" and MAGICC in "Hector mode"? I think this means -- is it possible to run Hector to free run after a certain point, in the way that MAGICC does, and is it then possible to run MAGICC in a free run set-up from the initial year, in the way that Hector does.

    Running MAGICC in a "Hector mode" I think would 100% require collaboration? Maybe not but it would be harder with out the collab.

# Meeting 12/20/2024
## Notes
Although there are similarities and some differences between MAGICC and Hector + Matilda we need to be very intentional about statements we make in support of one over the other and we need to have a realy good defenisble reason for using one over the other. There are important policy implications in the tails of distributions that we want to make sure we are appropriately informing. And so we need to be confident and knowledgable to the extent that we can about our ability to characterize the uncertainty in the tails of the distributions. 

It is our burden in any paper that we may end uo writing up for this to explain the differences that we see or will be showing in the paper -- My burden, I need to make sure that I am able to explain the reasoning behind it. This is not only important for me to provie that I can do this shit but also it is important for JGCRI beyond my expiration date. If it can be used and explained clearly the use of the tool will grow. So, with any publication that will come out of this (as should be our goal), a MAGICC v. Hector + Matilda comparison must have some context. We can't just say "the models are different and we don't know why." We need to explain clearly why they are different.

## Experiments 
1. We want to have an experiment where we use Hector + Matilda to emulate MAGICC results -- this can be done fairly simply in Matilda using MAGICC results to constrain (and weight) Hector model outputs. I think I would do this by creating a MAGICC scoring criterion?  There are other ways for this to be done -- RMSE calculation and pick those that have lowest RMSE -- this is goign to be the same thing as finding the highest likelihood. This will be done using the future projections of MAGICC.
2. How do the parameters of this Hector in MAGICC emulation mode results compare to what the Hector MAtilda run normally using historical data as a "constraint".










