# Chapter 24. Markov Models and Cost Effectiveness Analysis: Applications in Medical Research

This directory contains the code used in the following publication:

Komorowski M. and Raffa J. **Markov Models and Cost Effectiveness Analysis: Applications in Medical Research**, in *Secondary analysis of Electronic Health Record Data*, Springer, [Under Review]

Code is provided in Matlab&reg; format.  An `R` version has been added post-publication for those who are interested.

## Summary of Publication

This case study describes common Markov models, their specific application in medical research, health economics and cost-effectiveness analysis.

## Replicating this Publication

The work presented in this case study can be replicated as follows:

* `health_forecast.m` : This function computes 100 Monte-Carlo simulations of a 5-day health forecast and displays the results.

* `IED_transition.m` : This function computes and displays the proportion of patients in each state (Intubated, Extubated, or Dead), following the transition matrix in the intervention group.

* `MCMC_solver.m` : This function computes 10.000 Monte Carlo simulations for both the control and intervention group, and computes the distribution of ventilator-free days.

* `Matlab_2R_health_forecast.m` : _insert_

* `MCMC_solver.R`: An `R` implementation of `MCMC_solver.m`



***
Part of the wider **[Secondary Analysis of Electronic Health Records](https://github.com/MIT-LCP/critical-data-book)** book
***
