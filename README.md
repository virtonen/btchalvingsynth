# Estimating the Impact of the Bitcoin Halving on its Price Using Synthetic Control

**Name:** Vladislav Virtonen

## Background

New Bitcoin is created through a process called mining, where participants, known as miners, validate transactions and add them to the blockchain in exchange for newly issued Bitcoin. Bitcoin halving is a scheduled event that reduces the rate at which new Bitcoin is issued, cutting the reward for miners in half approximately every four years. This built-in supply reduction slows Bitcoin’s inflation and reinforces its scarcity, making new supply increasingly limited over time. Historically, halvings have been associated with upward price trends, as lower supply, combined with steady or growing demand, can create upward pressure on the price. I have noticed a lot of analysts and publications highlighting this association and even inferring causation when no one has conducted a proper causal analysis. However, correlation does not imply causation.

## Aim

This is why I gathered data on the 2024 and 2020 Bitcoin halvings and set out to build an observational study using a causal model to control for other factors influencing Bitcoin’s price (macroeconomic conditions, regulatory developments, growing adoption) and isolate the effect of halving on price. With this model, I intend to achieve a balance close to what a randomized control trial (RCT) would because it is not feasible to conduct an RCT in this context – nobody can randomly assign cryptocurrencies to treated and control groups to conduct an interventional study like this. Only through achieving such balance is it possible to say that this specific treatment (halving) influenced the outcome (price) to a certain degree.

## Method

I use synthetic control, which is a statistical method co-developed by Prof. Diamond to estimate the causal effect of an event by constructing a synthetic version of the treated unit using a weighted combination of similar, unaffected units. Instead of comparing Bitcoin’s price directly to another cryptocurrency (which may not be a good match), this method creates a synthetic Bitcoin from a mix of other cryptocurrencies that closely track Bitcoin’s price movements before the halving. If the real Bitcoin price diverges from this synthetic version after the halving, I interpret that difference as the estimated impact of the halving. Synthetic control is ideal in my study because it helps create a more credible counterfactual—what Bitcoin’s price might have looked like without the halving—while controlling for broader market trends.

## Findings

I find evidence that the 2024 halving had a positive effect on Bitcoin’s price, with the estimated impact accounting for about one-fifth of Bitcoin’s total percentage growth over the 17-month study period. However, when applying the same method to the 2020 halving, I do not find a statistically significant causal effect, likely due to broader market disruptions at the time when COVID-19 began. This is the first study to analyze Bitcoin halvings causally.
