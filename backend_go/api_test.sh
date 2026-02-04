#!/bin/bash

BASE_URL="http://localhost:8080"

echo "=== Health Check ==="
http GET $BASE_URL/health

echo -e "\n=== Register User ==="
http POST $BASE_URL/auth/register \
  email=agung@test.com \
  password=password123 \
  name="Agung" \
  username=agungknwn

echo -e "\n=== Login ==="
http POST $BASE_URL/auth/login \
  email=agung@test.com \
  password=password123

USER_ID="agungknwn"

echo -e "\n=== Create Budget ==="
http POST $BASE_URL/users/$USER_ID/budgets \
  monthYear=2024-02 \
  monthlyBudget:=5000000

echo -e "\n=== List Budgets ==="
http GET $BASE_URL/users/$USER_ID/budgets

echo -e "\n=== Create Expense ==="
http POST $BASE_URL/users/$USER_ID/expenses \
  amount:=50000 \
  category="food" \
  description="Lunch" \
  date="2024-02-04" \
  monthYear="2024-02"

echo -e "\n=== List Expenses ==="
http GET $BASE_URL/users/$USER_ID/expenses
