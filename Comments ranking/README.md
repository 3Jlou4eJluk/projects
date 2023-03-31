# Ranking Comments with Machine Learning

Ideas:
- Do the preprocessing by searching for meta-features in parallel (see below).
- Use the sentence_transformers library to extract features.
- Try different approaches: pointwise (using regression, we calculate a number describing how high a comment will have a rating), pairwise (we predict the probability that the first text is better than the second), listwise.
- First, train simple models: linear regression with regularization, XGBoost, Lightgbm on the output space, or by reducing it using PCA/UMAP/Isomap/TSNE.
- Try to train a neural network on the output space, or on a reduced one.

But we didn't have enough resources.

As a result , it was done:

1. EDA, extraction of meta-features
2. Calculation of vector representations for sentences
3. Creating a training sample: meta-features + cosine proximity of the post text and the comment text. The selection consists of all possible tuples (post_features, comments_features, score)
4. Training simple models
5. Neural network training
6. Score will be evaluated when splitting the training sample in the proportions of 2 to 1.