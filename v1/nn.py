import time
from matplotlib import pyplot as plt
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import OneHotEncoder, StandardScaler
from sklearn.impute import SimpleImputer
from data import load_data
import tensorflow as tf
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Dense, ELU, Dropout
from tensorflow.keras.optimizers import Adam
from tensorflow.keras.callbacks import EarlyStopping
from sklearn.metrics import mean_squared_error

# Load the data
df = load_data()

# Feature Engineering
df = pd.get_dummies(df, columns=['sex', 'pool'], dtype='int')
df = df.sort_values(by=['swimmer_num_id', 'race_date'])

# Sélection des features et de la cible
features = ['age', 'sex_M', 'pool_50m', 'previous_time', 'days_since_last_race', 'swimmer_num_id', 'trend_score', 'first_race_age']
target = 'time'

print(df[features + [target]].describe())

df = df.dropna()

# Préparer les données
X = df[features]
y = df[target]

# Split des données
x_train, x_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Normalisation des données
scaler = StandardScaler()
x_train = scaler.fit_transform(x_train)
x_test = scaler.transform(x_test)

def build_models():
    tf.random.set_seed(20)

    # model_1 = Sequential([
    #     Dense(16, activation=ELU(alpha=1.0), input_shape=(x_train.shape[1],)),
    #     Dense(8, activation=ELU(alpha=1.0)),
    #     Dense(4, activation=ELU(alpha=1.0)),
    #     Dense(1, activation='linear')
    # ], name='model_1')

    # model_2 = Sequential([
    #     Dense(16, activation='relu', input_shape=(x_train.shape[1],)),
    #     Dense(8, activation='relu'),
    #     Dense(4, activation='relu'),
    #     Dense(1, activation='linear')
    # ], name='model_2')

    # model_3 = Sequential([
    #     Dense(4, activation='relu', input_shape=(x_train.shape[1],)),
    #     Dense(8, activation='relu'),
    #     Dense(4, activation='relu'),
    #     Dense(1, activation='linear')
    # ], name='model_3')

    # model_4 = Sequential([
    #     Dense(8, activation=ELU(alpha=1.0), input_shape=(x_train.shape[1],)),
    #     Dense(4, activation=ELU(alpha=1.0)),
    #     Dense(1, activation='linear')
    # ], name='model_4')

    # model_list = [model_1, model_2, model_3, model_4]

    model_2 = Sequential([
        Dense(16, activation='relu', input_shape=(x_train.shape[1],)),
        Dense(8, activation='relu'),
        Dense(4, activation='relu'),
        Dense(1, activation='linear')
    ], name='model')

    model_list = [model_2]
    return model_list


nn_models = build_models()
model_results = {}

for model in nn_models:
    start_time = time.time()
    model.compile(
        loss='mse',
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001)
    )

    print(f"\nEntraînement de {model.name}...")
    model.summary()

    model.fit(
        x_train, y_train,
        epochs=100,
        batch_size=32,
        validation_split=0.1,
        verbose=0
    )

    yhat_train = model.predict(x_train)
    yhat_test = model.predict(x_test)

    # Check for NaNs in predictions
    if np.isnan(yhat_train).any() or np.isnan(yhat_test).any():
        print(f"Model {model.name} - Predictions contain NaNs")
        continue

    rmse_train = np.sqrt(mean_squared_error(y_train, yhat_train))
    rmse_test = np.sqrt(mean_squared_error(y_test, yhat_test))

    print(f"Model {model.name} - RMSE on Training Set: {rmse_train:.4f}")
    print(f"Model {model.name} - RMSE on Test Set: {rmse_test:.4f}\n")
    
    print(f"Training time: {time.time() - start_time:.2f} seconds\n")
    
    # save the model
    # nn_models[f'{distance} {stroke}'] = model

    plt.figure(figsize=(10, 6))
    plt.scatter(y_test, yhat_test, alpha=0.5, label="Predictions")
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', label="Perfect prediction")
    plt.xlabel("True Times")
    plt.ylabel("Predicted Times")
    plt.title("Model Prediction vs. Actual Times")
    plt.legend()
    plt.grid(True)
    plt.show()