import requests
from bs4 import BeautifulSoup
import time
import random
from fake_useragent import UserAgent

from swim_database import connect_to_db, create_tables, get_done_swimmers, get_races, insert_swimmer, insert_race, get_f_todo_swimmers, get_todo_swimmers, insert_split, update_swimmer_has_results

def retrieve_swimmers(url, start, end, increment):
    all_results = []

    while start < end:
        
        ua = UserAgent()
        headers = {'User-Agent': ua.random}
        # Construct the URL for each page
        call = url + str(start)
        
        start_time = time.time()
        # Make a request to the webpage
        response = requests.get(call, headers=headers)
        
        response_time = time.time() - start_time

        # Check if the request was successful
        if response_time > 10:
            print(f"Failed to retrieve page at {call}")
            print(f"Last working id is {start}")
            break
        
        # Parse the page content with BeautifulSoup
        soup = BeautifulSoup(response.text, 'html.parser')
        
        # Extract the relevant data
        table = soup.find("table", class_="rankingList")  # Example selector

        results = table.find_all('tr', class_=['rankingList0', 'rankingList1'])

        # If no more results, break the loop
        if not results:
            break
        
        # Store the results
        for result in results:
            cells = result.find_all('td')

            athlete_cell = cells[0]  # The first <td> contains the athlete's name and link
            athlete_name = athlete_cell.text.strip()
            
            # Find the <a> tag and extract the 'athleteId' from the href
            athlete_link = athlete_cell.find('a')
            athlete_id = None
            if athlete_link and 'href' in athlete_link.attrs:
                href = athlete_link['href']
                athlete_id = href.split('athleteId=')[1]
            
            # Extract the rest of the data (excluding the athlete's name)
            other_data = [cell.text.strip() for cell in cells[1:9]]  # Extract all data except name, date, and city
            
            # Step 7: Extract the date (10th <td> cell) and clean it (without formatting)
            date_text = cells[9].text.strip()  # Get the raw date text
            date_text_clean = date_text.replace('\xa0', ' ')  # Replace non-breaking spaces

            # Step 8: Extract the city (11th <td> cell)
            city = cells[10].text.strip()

            # Combine athlete's name, athleteId, other data, cleaned date, and city
            if athlete_name == "Anonymous Athlete":
                continue
            row_data = [athlete_name.split(", ")[0], athlete_name.split(", ")[1], athlete_id] + other_data + [date_text_clean, city]
            
            # SELECTION DE VARIABLES uniquement avec un temps qui donne plus de 400 pts FINA
            if int(row_data[7]) < 400:
                return all_results
            all_results.append(row_data)
        # Increment the start value for the next page
        start += increment
        time.sleep(random.uniform(10, 20))
    return all_results

def retrieve_and_insert_swimmers(conn, url, start, end, increment, gender):
    # Retrieve all swimmers from the given URL
    results = retrieve_swimmers(url, start, end, increment)
    
    for item in results:
        swimmer = {
            's_id': item[2],
            'lastname': item[0],
            'firstname': item[1],
            'birthyear': item[3],
            'sex': gender,  # Gender-specific based on the call
            'nationality': item[4],
            'last_club': item[5],
            'pb': item[6]
        }

        insert_swimmer(conn, swimmer)

def extract_splits(onmouseover_attr):
    """
    Extracts split times from the onmouseover attribute.
    Returns a list of tuples (distance, time) or None if no splits found.
    """
    onmouseover_attr.split("('")[1].split("')")[0]
    table = BeautifulSoup(onmouseover_attr, "html.parser")
    
    splits = table.find_all('tr')

    all_splits = []

    last_dist = "0m"

    for split in splits:
        split = [td.text for td in split.find_all('td')]
        if split[0] == '' :
            continue
        subdist = f"{int(split[0][:-1]) - int(last_dist[:-1])}m"

        split_dist = split[0]
        split_time = split[1]
        subsplit_dist = subdist
        subsplit_time = split[2]

        all_splits.append({"split_dist": split_dist, "split_time": split_time, "subsplit_dist": subsplit_dist, "subsplit_time":subsplit_time})
        last_dist = split[0]
    return all_splits

def retrieve_race(conn, s_id):
    
    # Some races are less relevant (see ChatGPT discussion 'Analyse résultats natation')
    
    # styles = {2: ["100m", "Freestyle"], 5: ["400m", "Freestyle"], 18: ["200m", "Medley"],}
    # styles = {1: ["50m", "Freestyle"], 2: ["100m", "Freestyle"], 3: ["200m", "Freestyle"], 5: ["400m", "Freestyle"], 6: ["800m", "Freestyle"], 8: ["1500m", "Freestyle"],
    #           9: ["50m", "Backstroke"], 10: ["100m", "Backstroke"], 11: ["200m", "Backstroke"],
    #           12: ["50m", "Breaststroke"], 13: ["100m", "Breaststroke"], 14: ["200m", "Breaststroke"],
    #           15: ["50m", "Butterfly"], 16: ["100m", "Butterfly"], 17: ["200m", "Butterfly"],
    #           20: ["100m", "Medley"], 18: ["200m", "Medley"], 19: ["400m", "Medley"]}

    styles = {2: ["100m", "Freestyle"], 3: ["200m", "Freestyle"], 5: ["400m", "Freestyle"],
              10: ["100m", "Backstroke"],
              13: ["100m", "Breaststroke"],
              16: ["100m", "Butterfly"], 
              18: ["200m", "Medley"]}

    for style in styles.keys():
        url = "https://www.swimrankings.net/index.php?page=athleteDetail&athleteId="+s_id+ "&styleId="+str(style)
        distance = styles[style][0]
        stroke = styles[style][1]

        ua = UserAgent()
        headers = {'User-Agent': ua.random}
        
        start_time = time.time()
        response = requests.get(url, headers)

        if time.time() - start_time > 10:
            print("Took to long to find results for swimmer : "+s_id+" for style : "+ str(style))
            break
        print("Swimmer : "+s_id+" for style : "+ str(style))
        soup = BeautifulSoup(response.text, 'html.parser')

        # 2 tables : 25m and 50m pool
        table = soup.find("table", class_="twoColumns")
        if table == None:
            print(table)
            print("No results for swimmer : "+s_id+" for style : "+ str(style))
            continue
        for t in table.find_all("table", class_="athleteRanking"):
            
            pool =  "25m" if t.find("th").text.find('25') > 0 else "50m"

            results = t.find_all('tr', class_=['athleteRanking0', 'athleteRanking1'])
            
            # Each table : all results
            for result in results:
                cells = result.find_all('td')

                other_data = [cell.text.strip() for cell in cells]
                r_time = other_data[0]
                r_points = other_data[1]
                r_date = other_data[2].replace('\xa0', ' ')
                r_place = other_data[3]
                row_data = {"s_id": s_id, "distance": distance, "stroke": stroke, "pool": pool, "time": r_time, "points": r_points, "race_date": r_date, "place": r_place}

                # Handle split-times
                time_link = result.find('a', class_='time')
                onmouseover_attr = time_link.get('onmouseover')
                splits = extract_splits(onmouseover_attr)
                
                r_id = insert_race(conn, row_data)

                for split in splits:
                    insert_split(conn, r_id, split)

                
        time.sleep(random.uniform(10, 20))
    update_swimmer_results(conn, s_id)
    print("Swimmer "+str(s_id)+" done")

def update_swimmer_results(conn, s_id):
    update_swimmer_has_results(conn, s_id)

def retrieve_and_insert_races(conn):
    # swimmers = get_todo_swimmers(conn)
    swimmers = get_f_todo_swimmers(conn)
    for swimmer in swimmers:
        retrieve_race(conn, swimmer[0])

# Base URL where the results are listed
m_url = "https://www.swimrankings.net/index.php?page=rankingDetail&rankingClubId=9268305&firstPlace="
f_url = "https://www.swimrankings.net/index.php?page=rankingDetail&rankingClubId=9268848&firstPlace="

# Initialize the starting point (1, 26, 51,...)
start = 1
m_end = 12000
f_end = 12635
increment = 25


if __name__ == "__main__":
    conn = connect_to_db()

    if conn:
        
        # Create the tables only if needed
        # create_tables(conn)

        # get all Belgian Women (based on 100m freestyle, since it is the most known competition)
        # retrieve_and_insert_swimmers(conn, m_url, start, m_end, increment, "M") # ALL MEN retrieveD

        # retrieve_and_insert_swimmers(conn, f_url, start, f_end, increment, "F") # ALL WOMEN retrieveD

        retrieve_and_insert_races(conn)

        print("get races")
        races = get_races(conn)
        # db_from_club()

        conn.close()