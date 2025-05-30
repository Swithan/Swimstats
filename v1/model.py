
import numpy as np
import pandas as pd
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
import math, copy
from sklearn.metrics import confusion_matrix



data = pd.read_csv('results.csv')
data

x = data[['']].values  
y = data['time_millisecond'].values  


scaler_x = StandardScaler()
scaler_y = StandardScaler()

x = scaler_x.fit_transform(x)
y = scaler_y.fit_transform(y.reshape(-1, 1))

x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.4, random_state=42)

#polynomial
"""
# Chargement des données
data = pd.read_csv('data.csv')

# Séparation des caractéristiques et de la cible
x = data[['x_1', 'x_2', 'x_3', 'x_4', 'x_5', '...', 'x_n']].values  
y = data['y'].values  

# Génération des termes polynomiaux de degré 3
poly = PolynomialFeatures(degree=3)
x_poly = poly.fit_transform(x)

# Standardisation des données polynomiales
scaler_x = StandardScaler()
x_poly = scaler_x.fit_transform(x_poly)
x_train, x_test, y_train, y_test = train_test_split(x, y, test_size=0.4, random_state=42)
"""
# /Polynomial

def sigmoid(z):

    g = 1/(1+np.exp(-z))


    return g


def compute_cost(X, y, w, b, lambda_= 1):

    m, n = X.shape
    
    cost = 0.
                                              
    for i in range(m):
        z = np.dot(X[i],w)+b
        f_wb = sigmoid(z)
        cost += -y[i]*np.log(f_wb) - (1-y[i])*np.log(1-f_wb)
    total_cost = cost/m

    reg_cost = (lambda_ / (2 * m)) * np.sum(np.square(w))
    total_cost += reg_cost

    return total_cost

def compute_gradient(X, y, w, b, lambda_=1):

    m, n = X.shape
    dj_dw = np.zeros(w.shape)
    dj_db = 0.

    for i in range(m):
        f_wb_i = sigmoid(np.dot(X[i],w) + b)          
        err_i  = f_wb_i  - y[i]                      
        for j in range(n):
            dj_dw[j] = dj_dw[j] + err_i * X[i,j]     
    dj_db = dj_db + err_i
    dj_dw = dj_dw/m                                  
    dj_db = dj_db/m                                  
    dj_dw += (lambda_ / m) * w
    return dj_db, dj_dw


def gradient_descent(X, y, w_in, b_in, cost_function, gradient_function, alpha, num_iters, lambda_):


    m = len(X)

    J_history = []
    w_history = []

    for i in range(num_iters):

        dj_db, dj_dw = gradient_function(X, y, w_in, b_in, lambda_)

        w_in = w_in - alpha * dj_dw
        b_in = b_in - alpha * dj_db
        
        if i<100000:      
            J_history.append( cost_function(X, y, w_in, b_in, lambda_))
        
        if i > 1 and abs(J_history[-1] - J_history[-2]) < 0.000001:
            print(f"Early stopping at iteration {i} as cost change is less than 0.000001")
            break 
            
        if i% math.ceil(num_iters / 10) == 0:
            print(f"Iteration {i:4}: Cost {J_history[-1]} ",
                  f"dj_dw: {dj_dw}, dj_db: {dj_db}  ",
                  f"w_in: {w_in}, b_in:{b_in}")

    return w_in, b_in, J_history, w_history 


np.random.seed(1)
initial_w = np.zeros(X_train.shape[1])  
initial_b = 0

lambda_=0.01
iterations = 1000
alpha = 0.003

w,b, J_history,_ = gradient_descent(X_train ,y_train, initial_w, initial_b, compute_cost, compute_gradient, alpha, iterations, lambda_)