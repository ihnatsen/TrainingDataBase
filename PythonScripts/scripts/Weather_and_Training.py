import pandas as pd
df = pd.read_csv(r'D:\projects\scripts\INPUT\weather.csv')
df[['datetime', 'temp']].to_csv(r'D:\projects\scripts\OUTPUT\weather.csv', index=False)

df = pd.read_csv(r'D:\projects\scripts\INPUT\training.csv')
    df[['data_training', 'start_time', 'end_time', 'distance']].to_csv(r'D:\projects\scripts\OUTPUT\training.csv', index=False)

