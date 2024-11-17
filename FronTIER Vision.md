from google.colab import files
uploaded = files.upload()

import pandas as pd

# Load current customers data
customers = pd.read_csv('current_customers.csv')

# Comprehensive product catalog with all products offered
# Recreate the products DataFrame with the Category column
products = pd.DataFrame([
    {'Product': 'Fiber 500', 'Bandwidth': 500, 'Devices': 1, 'Price': 45, 'Category': 'Internet'},
    {'Product': 'Fiber 1 Gig', 'Bandwidth': 1000, 'Devices': 1, 'Price': 65, 'Category': 'Internet'},
    {'Product': 'Fiber 2 Gig', 'Bandwidth': 2000, 'Devices': 2, 'Price': 99, 'Category': 'Internet'},
    {'Product': 'Fiber 5 Gig', 'Bandwidth': 5000, 'Devices': 1, 'Price': 129, 'Category': 'Internet'},
    {'Product': 'Fiber 7 Gig', 'Bandwidth': 7000, 'Devices': 2, 'Price': 299, 'Category': 'Internet'},
    {'Product': 'Whole-Home WiFi', 'Bandwidth': 0, 'Devices': 0, 'Price': 10, 'Category': 'WiFi Add-on'},
    {'Product': 'WiFi Security', 'Bandwidth': 0, 'Devices': 0, 'Price': 5, 'Category': 'Security'},
    {'Product': 'Premium Tech Pro', 'Bandwidth': 0, 'Devices': 0, 'Price': 20, 'Category': 'Support'},
])

from sklearn.preprocessing import MinMaxScaler

customers['total_devices'] = customers['wireless_clients_count'] + customers['wired_clients_count']
customers['needs_wifi_extenders'] = (customers['total_devices'] > 5).astype(int)
customers['needs_security'] = (customers['rssi_mean'] < -70).astype(int)  # Poor signal strength
customers['needs_support'] = (customers['tx_avg_bps'] > 1e6).astype(int)  # High data transfer rates
# Add the missing 'poor_signal' feature
customers['poor_signal'] = (customers['rssi_mean'] < -70).astype(int)





# Normalize customer features
customer_features = customers[['total_devices', 'rx_avg_bps', 'tx_avg_bps', 
                               'needs_wifi_extenders', 'needs_security', 'needs_support']]
scaler = MinMaxScaler()
customer_features_scaled = scaler.fit_transform(customer_features)

# Normalize product features (one-hot encode categories)
products = pd.get_dummies(products, columns=['Category'])
product_features = products[['Bandwidth', 'Devices', 'Price'] + list(products.filter(like='Category').columns)]
product_features_scaled = scaler.fit_transform(product_features)

from sklearn.metrics.pairwise import cosine_similarity

# Use only numerical columns for similarity computation
product_similarity_features = ['Bandwidth', 'Devices', 'Price']  # Exclude one-hot encoded categories
product_features_similarity_scaled = scaler.fit_transform(products[product_similarity_features])

# Ensure customer features have the same numerical scope
customer_similarity_features = ['total_devices', 'rx_avg_bps', 'tx_avg_bps']
customer_features_similarity_scaled = scaler.fit_transform(customers[customer_similarity_features])

# Compute similarity scores
similarity = cosine_similarity(customer_features_similarity_scaled, product_features_similarity_scaled)


# Generate top recommendations for each customer
recommendations = {}
for idx, customer_scores in enumerate(similarity):
    top_products = products.iloc[customer_scores.argsort()[::-1]].head(3)
    recommendations[customers.iloc[idx]['acct_id']] = top_products['Product'].tolist()

# Display content-based recommendations
for customer, recs in recommendations.items():
    print(f"Customer {customer}: Content-Based Recommended Products: {', '.join(recs)}")

# Create a binary interaction matrix for all products
interaction_matrix = pd.DataFrame({
    'acct_id': customers['acct_id'],
    'Fiber 500': (customers['extenders'] > 0).astype(int),
    'Fiber 1 Gig': (customers['extenders'] > 1).astype(int),
    'Fiber 2 Gig': (customers['extenders'] > 2).astype(int),
    'Whole-Home WiFi': customers['needs_wifi_extenders'],
    'WiFi Security': customers['needs_security'],
    'Premium Tech Pro': customers['needs_support'],
}).set_index('acct_id')

# Ensure additional columns are consistent
interaction_matrix['Whole-Home WiFi'] = (customers['total_devices'] > 5).astype(int)
interaction_matrix['WiFi Security'] = (customers['poor_signal'] > 0).astype(int)
interaction_matrix['Fiber 5 Gig'] = (customers['extenders'] > 3).astype(int)  # Example threshold
interaction_matrix['Fiber 7 Gig'] = (customers['extenders'] > 4).astype(int)  # Example threshold
# Fill NaN values with 0
interaction_matrix.fillna(0, inplace=True)


# Convert to sparse matrix
from scipy.sparse import csr_matrix
interaction_sparse = csr_matrix(interaction_matrix.values)

# Apply SVD
from sklearn.decomposition import TruncatedSVD
svd = TruncatedSVD(n_components=5, random_state=42)
user_factors = svd.fit_transform(interaction_sparse)
item_factors = svd.components_

# Predict scores
predicted_scores = user_factors @ item_factors

import numpy as np

# Normalize scores
content_scores = similarity / np.max(similarity)
collab_scores = predicted_scores / np.max(predicted_scores)

# Combine with weighted average
alpha = 0.6
final_scores = alpha * content_scores + (1 - alpha) * collab_scores

# Generate final recommendations
final_recommendations = {}
for idx, customer_scores in enumerate(final_scores):
    top_products = products.iloc[customer_scores.argsort()[::-1]].head(3)
    final_recommendations[customers.iloc[idx]['acct_id']] = top_products['Product'].tolist()

# Display final recommendations
for customer, recs in final_recommendations.items():
    print(f"Customer {customer}: Final Recommended Products: {', '.join(recs)}")


from sklearn.metrics import mean_squared_error

# Example RMSE for collaborative filtering predictions
actual = interaction_matrix.values
predicted = np.clip(predicted_scores, 0, 1)  # Ensure scores are between 0 and 1
rmse = np.sqrt(mean_squared_error(actual, predicted))
print(f"RMSE: {rmse}")


from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder

# Prepare interaction data
interaction_data = interaction_matrix.reset_index().melt(id_vars='acct_id', var_name='product_id', value_name='interaction')

# Keep only interactions (positive samples)
positive_samples = interaction_data[interaction_data['interaction'] > 0]

# Add negative samples (non-interactions)
negative_samples = interaction_data[interaction_data['interaction'] == 0].sample(len(positive_samples), random_state=42)

# Combine positive and negative samples
training_data = pd.concat([positive_samples, negative_samples], ignore_index=True)

# Encode acct_id and product_id
acct_encoder = LabelEncoder()
product_encoder = LabelEncoder()

training_data['acct_id'] = acct_encoder.fit_transform(training_data['acct_id'])
training_data['product_id'] = product_encoder.fit_transform(training_data['product_id'])

# Train-test split
X = training_data[['acct_id', 'product_id']].values
y = training_data['interaction'].values

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

import tensorflow as tf
from tensorflow.keras import layers, models

# Define model parameters
num_users = training_data['acct_id'].nunique()
num_products = training_data['product_id'].nunique()
embedding_size = 50

# User and product embedding layers
user_input = layers.Input(shape=(1,))
product_input = layers.Input(shape=(1,))

user_embedding = layers.Embedding(input_dim=num_users, output_dim=embedding_size, input_length=1)(user_input)
product_embedding = layers.Embedding(input_dim=num_products, output_dim=embedding_size, input_length=1)(product_input)

# Flatten embeddings
user_vector = layers.Flatten()(user_embedding)
product_vector = layers.Flatten()(product_embedding)

# Concatenate user and product vectors
concatenated = layers.Concatenate()([user_vector, product_vector])

# Hidden layers
dense_1 = layers.Dense(128, activation='relu')(concatenated)
dense_2 = layers.Dense(64, activation='relu')(dense_1)

# Output layer
output = layers.Dense(1, activation='sigmoid')(dense_2)

# Build the model
model = models.Model(inputs=[user_input, product_input], outputs=output)
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['accuracy'])

# Model summary
model.summary()

# Train the model
history = model.fit(
    [X_train[:, 0], X_train[:, 1]],
    y_train,
    epochs=10,
    batch_size=128,
    validation_data=([X_test[:, 0], X_test[:, 1]], y_test),
    verbose=1
)

# Generate recommendations for each customer
unique_customers = training_data['acct_id'].unique()
unique_products = training_data['product_id'].unique()

recommendations = {}

for user_id in unique_customers:
    product_ids = unique_products
    predictions = model.predict([np.array([user_id] * len(product_ids)), product_ids])
    top_products = product_encoder.inverse_transform(np.argsort(predictions.flatten())[::-1][:3])
    recommendations[acct_encoder.inverse_transform([user_id])[0]] = top_products.tolist()

# Display recommendations
for customer, recs in recommendations.items():
    print(f"Customer {customer}: Recommended Products: {', '.join(recs)}")

# Check product IDs in the training data
print("Products in training data:", training_data['product_id'].unique())

# Decode product IDs
decoded_products = product_encoder.inverse_transform(training_data['product_id'].unique())
print("Decoded products in training data:", decoded_products)

# Compute weights for products based on their frequency
from collections import Counter

product_counts = Counter(training_data['product_id'])
max_count = max(product_counts.values())

# Compute weights for each product
product_weights = {product: max_count / count for product, count in product_counts.items()}

# Add weights to training data
training_data['product_weight'] = training_data['product_id'].map(product_weights)

# Add synthetic interactions for underrepresented products
underrepresented_products = ['Whole-Home WiFi', 'WiFi Security', 'Premium Tech Pro']

for product in underrepresented_products:
    synthetic_data = pd.DataFrame({
        'acct_id': customers['acct_id'].sample(50, random_state=42),  # Randomly select 50 customers
        'product_id': product_encoder.transform([product] * 50),      # Encode the product
        'interaction': [1] * 50                                       # Positive interaction
    })
    training_data = pd.concat([training_data, synthetic_data], ignore_index=True)

# Hidden layers with L2 regularization
dense_1 = layers.Dense(128, activation='relu', kernel_regularizer=tf.keras.regularizers.l2(0.01))(concatenated)
dense_2 = layers.Dense(64, activation='relu', kernel_regularizer=tf.keras.regularizers.l2(0.01))(dense_1)

# Compute class weights for balancing
class_weights = {
    0: 1.0,  # Non-interactions
    1: 1.5   # Positive interactions
}

# Train the model with class weights
history = model.fit(
    [X_train[:, 0], X_train[:, 1]],
    y_train,
    epochs=10,
    batch_size=128,
    validation_data=([X_test[:, 0], X_test[:, 1]], y_test),
    class_weight=class_weights,
    verbose=1
)

from sklearn.metrics import mean_squared_error
import numpy as np

# Calculate RMSE
y_pred = model.predict([X_test[:, 0], X_test[:, 1]]).flatten()
rmse = np.sqrt(mean_squared_error(y_test, y_pred))
print(f"RMSE: {rmse}")

from sklearn.metrics import precision_score, recall_score, f1_score

# Binarize predictions (threshold = 0.5)
y_pred_binary = (y_pred > 0.5).astype(int)

# Calculate precision, recall, and F1-score
precision = precision_score(y_test, y_pred_binary)
recall = recall_score(y_test, y_pred_binary)
f1 = f1_score(y_test, y_pred_binary)

print(f"Precision: {precision:.4f}")
print(f"Recall: {recall:.4f}")
print(f"F1-Score: {f1:.4f}")

from sklearn.metrics import roc_auc_score

# Calculate AUC
auc = roc_auc_score(y_test, y_pred)
print(f"AUC-ROC: {auc:.4f}")

# Save metrics to a dictionary
metrics = {
    'RMSE': rmse,
    'Precision': precision,
    'Recall': recall,
    'F1-Score': f1,
    'AUC-ROC': auc
}

# Display metrics
for metric, value in metrics.items():
    print(f"{metric}: {value:.4f}")

