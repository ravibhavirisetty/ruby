require 'spreadsheet'
require 'date'
require 'nokogiri'
require 'open-uri'

# path to follow = /details/133/variable, where variable goes from 623 to 337
# pirateData = lat, long, attack ID, Date, Vessel Type, Status, url extension to reach summary of event

# This script parses through the differnt points displayed on the map at
# http://www.icc-ccs.org/piracy-reporting-centre/live-piracy-map/piracy-map-2013/
# and extracts information from them. The information for the pirateData
# array was pulled straight from the HTML of the website

# There are 260 links about different acts of piracy on the website.
# To access these links you need to go to baseURL + urlExtension

baseURL = "http://www.icc-ccs.org/piracy-reporting-centre/live-piracy-map/piracy-map-2013"
pirateData = ["4.8833333333333, -1.6833333333332803, 264-13 , 2013-12-31 , General Cargo , Boarded ,/details\/133\/623\/","10.300555555555556,-75.56055555555555, 263-13 , 2013-12-28 , Crude Tanker , Boarded ,/details\/133\/622\/", "1.2602777777777778,104.06722222222223, 262-13 , 2013-10-13 , Tug and Barge , Boarded ,/details\/133\/621\/", "1.2561111111111, 104.11666666666997, 261-13 , 2013-12-18 , Tug , Boarded ,/details\/133\/620\/", "-24.05675421936364, -46.34490496317585, 260-13 , 2013-12-22 , Container , Boarded ,/details\/133\/619\/","3.9, 98.78333333333308, 259-13 , 2013-12-20 , Chemical Tanker , Boarded ,/details\/133\/618\/", "32.31164719970087, -9.248665021260535, 258-13 , 2013-12-19 , Bulk Carrier , Attempted ,/details\/133\/617\/","3.7908271192329708, 98.71034259796147, 257-13 , 2013-12-18 , Product Tanker , Boarded ,/details\/133\/616\/", "3.9022222222222, 98.78333333333308, 256-13 , 2013-12-19 , Chemical Tanker , Boarded ,/details\/133\/615\/", "1.3166666666666667,104.26666666666667, 255-13 , 2013-12-19 , Chemical Tanker , Attempted ,/details\/133\/614\/", "5.222246513227389, 3.36181640625, 254-13 , 2013-12-16 , Chemical Tanker , Boarded ,/details\/133\/613\/", "-0.25166666666666665,117.58416666666666, 253-13 , 2013-12-18 , Bulk Carrier , Boarded ,/details\/133\/612\/", "-0.1,117.56666666666666, 252-13 , 2013-12-16 , Crude Tanker , Boarded ,/details\/133\/611\/", "1.1011111111111, 103.61666666666997, 251-13 , 2013-12-12 , Crude Tanker , Boarded ,/details\/133\/610\/", "1.4172222222222222,104.68333333333334, 250-13 , 2013-12-10 , Crude Tanker , Boarded ,/details\/133\/609\/", "12.868055555556, 47.866666666667015, 249-13 , 2013-12-09 , Bulk Carrier , Fired Upon ,/details\/133\/608\/", "12.833333333333, 47.81666666666706, 248-13 , 2013-12-09 , Crude Tanker , Fired Upon ,/details\/133\/607\/", "1.1166666666666667,103.58333333333333, 247-13 , 2013-12-07 , Crude Tanker , Boarded ,/details\/133\/606\/", "1.2, 103.60000000000002, 246-13 , 2013-09-22 , Tug and Barge , Boarded ,/details\/133\/605\/", "22.785833333333, 70.08333333333303, 245-13 , 2013-12-04 , Bulk Carrier , Boarded ,/details\/133\/604\/", "-3.7186111111111, 114.41666666666993, 244-13 , 2013-12-05 , Bulk Carrier , Attempted ,/details\/133\/603\/", "1.3783333333333334, 104.70583333333332, 243-13 , 2013-10-21 , Tug , Boarded ,/details\/133\/602\/", "20.591666666666665, 107.09666666666669, 242-13 , 2013-12-02 , Container , Boarded ,/details\/133\/601\/", "1.1,103.63333333333334, 241-13 , 2013-12-01 , Crude Tanker , Boarded ,/details\/133\/600\/", "Unknown, unknown, 237-13 , 2013-11-27 , Crude Tanker , Boarded ,/details\/133\/596\/", "-4.045277777777778,39.61666666666667, 239-13 , 2013-11-25 , Container , Boarded ,/details\/133\/598\/", "-5.991666666666666,106.91666666666667, 238-13 , 2013-11-23 , General Cargo , Boarded ,/details\/133\/597\/", "3.9, 98.76666666666699, 236-13 , 2013-11-16 , Product Tanker , Boarded ,/details\/133\/595\/", "1.7033333333333334, 101.495, 234-13 , 2013-11-24 , Chemical Tanker , Attempted ,/details\/133\/592\/", "-4.76,11.819166666666666, 233-13 , 2013-11-24 , Offshore Tug , Boarded ,/details\/133\/591\/", "3.921388888888889,98.75111111111111, 232-13 , 2013-11-23 , Bulk Carrier , Boarded ,/details\/133\/590\/", "1.7,101.53333333333333, 231-13 , 2013-11-22 , Product Tanker , Boarded ,/details\/133\/589\/", "22.633333333333333,69.88416666666667, 230-13 , 2013-11-21 , Crude Tanker , Boarded ,/details\/133\/587\/", "22.65,69.92944444444444, 229-13 , 2013-11-21 , Crude Tanker , Boarded ,/details\/133\/586\/", "8.5,-13.209166666666667, 228-13 , 2013-11-19 , Chemical Tanker , Boarded ,/details\/133\/585\/", "10.661907262406112, 107.0151431719496, 227-13 , 2013-11-08 , LPG Tanker , Boarded ,/details\/133\/584\/", "1.3833333333333, 104.70000000000005, 226-13 , 2013-11-14 , Product Tanker , Boarded ,/details\/133\/583\/", "-7.3188888888889, 48.60000000000002, 225-13 , 2013-11-09 , Chemical Tanker , Fired Upon ,/details\/133\/582\/", "-3.6666666666667, 114.43333333332998, 224-13 , 2013-11-09 , Bulk Carrier , Boarded ,/details\/133\/581\/", "-1.7291666666667, 116.64916666667, 223-13 , 2013-11-08 , Bulk Carrier , Boarded ,/details\/133\/580\/", "1.335, 103.29999999999995, 222-13 , 2013-11-07 , Chemical Tanker , Hijacked ,/details\/133\/578\/", "-5.6666666666667, 46.98333333333301, 221-13 , 2013-11-06 , Product Tanker , Fired Upon ,/details\/133\/577\/", "3.9094444444444445, 98.76666666666665, 220-13 , 2013-11-04 , Chemical Tanker , Boarded ,/details\/133\/576\/", "21.666666666666668, 88.01666666666665, 219-13 , 2013-11-02 , Container , Boarded ,/details\/133\/575\/", "1.3533333333333333, 104.40499999999997, 216-13 , 2013-10-30 , Asphalt\/Bitumen Tanker , Boarded ,/details\/133\/572\/", "22.816666666667, 70.08333333333303, 215-13 , 2013-10-30 , Chemical Tanker , Boarded ,/details\/133\/571\/", "21.748333333333335,91.63333333333334, 212-13 , 2013-10-28 , Container , Boarded ,/details\/133\/568\/", "3.6666666666666665, 103.93194444444441, 211-13 , 2013-10-26 , Product Tanker , Attempted ,/details\/133\/567\/", "3.9333333333333, 98.75, 210-13 , 2013-10-27 , Chemical Tanker , Boarded ,/details\/133\/566\/", "-7.0833333333333, 112.64999999999998, 209-13 , 2013-10-23 , Chemical Tanker , Boarded ,/details\/133\/565\/", "1.7022222222222223,101.44, 208-13 , 2013-10-22 , Chemical Tanker , Boarded ,/details\/133\/564\/", "22.81888888888889, 70.10500000000002, 207-13 , 2013-10-22 , LPG Tanker , Boarded ,/details\/133\/562\/", "18.400277777777777,-70.01666666666666, 206-13 , 2013-10-20 , LPG Tanker , Boarded ,/details\/133\/561\/", "3.783333333333333,98.77, 205-13 , 2013-10-22 , Chemical Tanker , Boarded ,/details\/133\/560\/", "6.802222222222222,-58.166666666666664, 204-13 , 2013-10-19 , Bulk Carrier , Boarded ,/details\/133\/559\/", "17.600277777777776, 83.4333333333334, 203-13 , 2013-10-20 , Crude Tanker , Boarded ,/details\/133\/558\/", "-0.23333333333333, 117.54999999999995, 202-13 , 2013-10-19 , Bulk Carrier , Boarded ,/details\/133\/557\/", "1.4166666666667, 104.56666666667001, 201-13 , 2013-10-19 , Product Tanker , Boarded ,/details\/133\/556\/", "-19.816666666667, 34.83333333333303, 200-13 , 2013-10-15 , Container , Boarded ,/details\/133\/555\/", "2.2666666666667, 104.79999999999995, 199-13 , 2013-10-10 , Product Tanker , Hijacked ,/details\/133\/554\/", "4.2, 7.107222222222163, 198-13 , 2013-10-03 , Chemical Tanker , Boarded ,/details\/133\/553\/", "-6.0025, 106.88333333333332, 197-13 , 2013-10-12 , Chemical Tanker , Boarded ,/details\/133\/552\/", "4.65, 52.31666666666706, 196-13 , 2013-10-11 , Crude Tanker , Fired Upon ,/details\/133\/551\/", "-0.25083333333333335, 117.68416666666667, 195-13 , 2013-10-10 , Bulk Carrier , Boarded ,/details\/133\/550\/", "1.1, 103.46666666667, 194-13 , 2013-10-07 , Product Tanker , Boarded ,/details\/133\/549\/", "1.12, 103.58333333333326, 193-13 , 2013-10-06 , Crude Tanker , Attempted ,/details\/133\/548\/", "1.0916666666666666, 103.47000000000003, 192-13 , 2013-10-07 , Product Tanker , Boarded ,/details\/133\/547\/", "1.1333333333333333, 103.58333333333326, 191-13 , 2013-10-06 , Crude Tanker , Boarded ,/details\/133\/546\/", "-0.1, 117.5333333333333, 190-13 , 2013-10-05 , Crude Tanker , Boarded ,/details\/133\/545\/", "-6.0169444444444, 106.88527777777995, 189-13 , 2013-09-21 , Product Tanker , Boarded ,/details\/133\/544\/", "0.9433333333333334, 104.01666666666665, 188-13 , 2013-10-01 , Chemical Tanker , Boarded ,/details\/133\/543\/", "3.95, 98.75, 187-13 , 2013-09-27 , Chemical Tanker , Boarded ,/details\/133\/542\/", "-0.6783333333333333,117.61666666666666, 186-13 , 2013-09-26 , Bulk Carrier , Boarded ,/details\/133\/541\/", "4.8666666666667, 104.08333333333007, 185-13 , 2013-09-23 , Offshore Tug , Boarded ,/details\/133\/539\/", "22.200833333333, 91.66666666666697, 184-13 , 2013-08-04 , Product Tanker , Boarded ,/details\/133\/538\/", "1.1166666666667, 103.61666666666997, 183-13 , 2013-09-23 , Crude Tanker , Boarded ,/details\/133\/537\/", "-0.26777777777778, 117.68333333332998, 182-13 , 2013-09-21 , Bulk Carrier , Boarded ,/details\/133\/536\/", "-7.1525,112.67, 181-13 , 2013-09-16 , Chemical Tanker , Boarded ,/details\/133\/535\/", "1.155, 103.57888888888885, 180-13 , 2013-09-15 , Crude Tanker , Boarded ,/details\/133\/534\/", "1.1016666666666665, 103.61833333333334, 179-13 , 2013-07-11 , Product Tanker , Boarded ,/details\/133\/532\/", "4.183333333333334,5.578333333333333, 178-13 , 2013-09-04 , Chemical Tanker , Fired Upon ,/details\/133\/531\/", "10.231666666666667,107.03472222222223, 177-13 , 2013-09-03 , Chemical Tanker , Boarded ,/details\/133\/530\/", "20.933333333333, 107.31666666667002, 176-13 , 2013-08-28 , Bulk Carrier , Boarded ,/details\/133\/529\/", "22.183333333333333, 91.70000000000004, 175-13 , 2013-08-27 , Container , Boarded ,/details\/133\/528\/", "3.783333333333333,98.66666666666667, 174-13 , 2013-08-23 , Livestock Carrier , Boarded ,/details\/133\/527\/", "4.051388888888889,8.036944444444444, 172-13 , 2013-06-13 , Offshore Tug , Boarded ,/details\/133\/526\/", "14.552222222222, 120.91666666666993, 171-13 , 2013-07-26 , Container , Boarded ,/details\/133\/525\/", "1.3833333333333333,104.5, 170-13 , 2013-08-02 , Product Tanker , Boarded ,/details\/133\/524\/", "-0.26916666666667, 117.60138888889003, 173-13 , 2013-08-23 , Bulk Carrier , Boarded ,/details\/133\/523\/", "-1.2516666666667, 117.60166666666998, 169-13 , 2013-08-23 , Bulk Carrier , Boarded ,/details\/133\/522\/", "22.18166666666667, 91.71000000000004, 168-13 , 2013-08-16 , Container , Boarded ,/details\/133\/521\/", "6.3363888888889, 3.4763888888888914, 167-13 , 2013-08-12 , Chemical Tanker , Hijacked ,/details\/133\/520\/", "6.173333333333333,3.4, 166-13 , 2013-08-15 , Chemical Tanker , Attempted ,/details\/133\/519\/", "-0.26666666666666666, 117.60000000000002, 164-13 , 2013-08-10 , Bulk Carrier , Boarded ,/details\/133\/517\/", "1.1, 103.63333333333333, 163-13 , 2013-08-02 , Crude Tanker , Boarded ,/details\/133\/516\/", "5.2166666666667, -4.053333333333285, 162-13 , 2013-07-31 , Bulk Carrier , Boarded ,/details\/133\/515\/", "31.198333333333334,29.901666666666667, 161-13 , 2013-07-31 , Container , Boarded ,/details\/133\/514\/", "3.5166666666666666, 6.083333333333371, 160-13 , 2013-07-30 , Chemical Tanker , Fired Upon ,/details\/133\/513\/", "4.266666666666667,7.933333333333334, 159-13 , 2013-07-24 , Product Tanker , Boarded ,/details\/133\/512\/", "22.263333333333332,91.8, 158-13 , 2013-07-27 , Chemical Tanker , Boarded ,/details\/133\/511\/", "-7.0916666666667, 112.65833333333, 157-13 , 2013-07-30 , Chemical Tanker , Boarded ,/details\/133\/510\/", "29.833333333333332, 32.575000000000045, 156-13 , 2013-07-27 , Container , Boarded ,/details\/133\/509\/", "1.1008333333333333, 104.16916666666668, 155-13 , 2013-07-29 , LPG Tanker , Boarded ,/details\/133\/508\/", "1.31166666667, 104.6916666666666, 154-13 , 2013-07-25 , Tug , Boarded ,/details\/133\/500\/", "1.26666666667, 104.616666667, 153-13 , 2013-07-24 , Tug , Boarded ,/details\/133\/499\/", "22.8, 70.04999999999995, 152-13 , 2013-07-24 , Chemical Tanker , Boarded ,/details\/133\/498\/", "-0.446944444444, 8.850000000000023, 151-13 , 2013-07-15 , Crude Tanker , Hijacked ,/details\/133\/497\/", "10.779811719258403, 106.70926971435551, 150-13 , 2013-07-21 , Product Tanker , Boarded ,/details\/133\/496\/", "6.09, 1.294999999999959, 149-13 , 2013-07-18 , Bulk Carrier , Attempted ,/details\/133\/495\/", "1.11666666667, 104.866666667, 148-13 , 2013-07-17 , General Cargo , Boarded ,/details\/133\/494\/", "-0.490277777778, 8.850000000000023, 147-13 , 2013-07-14 , Landing Craft , Boarded ,/details\/133\/493\/", "3.21666666667, 104.96666666700003, 146-13 , 2013-07-12 , Tug , Boarded ,/details\/133\/492\/", "13.4666666667, 43.01666666669996, 145-13 , 2013-07-16 , Chemical Tanker , Attempted ,/details\/133\/491\/", "5.483333333333333,1.6494444444444442, 144-13 , 2013-07-16 , Product Tanker , Hijacked ,/details\/133\/490\/", "6.28555555556, 3.3500000000000227, SUS 007-13 , 2013-07-10 , Chemical Tanker , Suspicious ,/details\/133\/489\/", "3.05361111111, 104.29999999999995, 143-13 , 2013-07-10 , Asphalt\/Bitumen Tanker , Boarded ,/details\/133\/488\/", "6.01666666667, 1.2999999999999545, 142-13 , 2013-06-13 , Chemical Tanker , Hijacked ,/details\/133\/487\/", "13.166666666666666, 43.10000000000002, 141-13 , 2013-07-08 , Bulk Carrier , Attempted ,/details\/133\/486\/", "1.1341666666666667,103.65, 140-13 , 2013-07-07 , Crude Tanker , Boarded ,/details\/133\/485\/", "12.9833333333, 43.10000000000002, SUS 006-13 , 2013-07-04 , Bulk Carrier , Suspicious ,/details\/133\/484\/", "-3.66888888889, 114.41666666700007, 139-13 , 2013-07-04 , Bulk Carrier , Boarded ,/details\/133\/483\/", "1.15833333333, 103.79999999999995, 138-13 , 2013-07-01 , Tug , Boarded ,/details\/133\/482\/", "22.9875, 70.23333333329992, 137-13 , 2013-06-30 , Bulk Carrier , Boarded ,/details\/133\/481\/", "-6.017222222222222, 106.88583333333326, 136-13 , 2013-06-27 , Chemical Tanker , Attempted ,/details\/133\/480\/", "4.5, 103.98333333300002, 135-13 , 2013-06-09 , Tug , Boarded ,/details\/133\/479\/", "4.51777777778, 113.866666667, 134-13 , 2013-06-17 , Product Tanker , Boarded ,/details\/133\/478\/", "1.15083333333, 103.633333333, 133-13 , 2013-06-20 , LPG Tanker , Boarded ,/details\/133\/477\/", "-1.1833333333333333, 117.20000000000004, 132-13 , 2013-06-19 , Bulk Carrier , Boarded ,/details\/133\/476\/", "9.23388888889, -13.950833333300011, 131-13 , 2013-06-19 , General Cargo , Boarded ,/details\/133\/475\/", "1.26, 104.12666666666667, 130-13 , 2013-05-12 , Tug and Barge , Boarded ,/details\/133\/474\/", "-4.56666666667, -81.30000000000001, 129-13 , 2013-05-24 , Chemical Tanker , Boarded ,/details\/133\/473\/", "-3.68333333333, 114.41666666700007, 128-13 , 2013-06-15 , Bulk Carrier , Attempted ,/details\/133\/472\/", "22.159444444444442,91.80277777777778, 127-13 , 2013-06-15 , Chemical Tanker , Boarded ,/details\/133\/471\/", "-1.20083333333, 117.21666666700003, 126-13 , 2013-06-13 , Bulk Carrier , Boarded ,/details\/133\/470\/", "-6.039444444444444,106.90722222222221, 125-13 , 2013-06-16 , Container , Boarded ,/details\/133\/469\/", "1.1, 103.60000000000002, 124-13 , 2013-06-13 , Crude Tanker , Boarded ,/details\/133\/468\/", "-1.08333333333, 117.23333333300002, 123-13 , 2013-06-12 , Crude Tanker , Boarded ,/details\/133\/467\/", "-3.70083333333, 114.46666666700003, 122-13 , 2013-06-10 , Bulk Carrier , Boarded ,/details\/133\/466\/", "3.8279553916911575, 98.73096110029383, 121-13 , 2013-06-08 , Chemical Tanker , Boarded ,/details\/133\/465\/", "3.86805555556, 5.466666666669994, 120-13 , 2013-05-24 , Product Tanker , Boarded ,/details\/133\/464\/", "-19.79972381143366, 34.829213460286496, 119-13 , 2013-06-01 , Chemical Tanker , Boarded ,/details\/133\/463\/", "11.6,49.25, 118-13 , 2013-06-05 , Dhow , Hijacked ,/details\/133\/462\/", "4.23583333333, 7.7625000000000455, 117-13 , 2013-06-04 , Offshore Supply Ship , Boarded ,/details\/133\/461\/", "4.7, 8.316666666670017, 116-13 , 2013-06-03 , Chemical Tanker , Fired Upon ,/details\/133\/460\/", "3.92972222222, 98.76666666670008, 115-13 , 2013-06-03 , Chemical Tanker , Attempted ,/details\/133\/459\/", "-1.16861111111, 117.25, 114-13 , 2013-06-03 , Bulk Carrier , Boarded ,/details\/133\/458\/", "31.2019444444, 29.76666666669996, 113-13 , 2013-05-27 , Bulk Carrier , Boarded ,/details\/133\/457\/", "-2.36777777778, -81, 112-13 , 2013-05-27 , Container , Boarded ,/details\/133\/456\/", "3.348888888888889, 100.1833333333334, 111-13 , 2013-05-07 , Fishing  , Hijacked ,/details\/133\/455\/", "31.2, 29.700000000000045, 110-13 , 2013-05-23 , Crude Tanker , Boarded ,/details\/133\/454\/", "-5.98333333333, 105.95000000000005, 109-13 , 2013-05-24 , Bulk Carrier , Boarded ,/details\/133\/453\/", "22.2838888889, 91.79999999999995, 108-13 , 2013-05-23 , Chemical Tanker , Boarded ,/details\/133\/452\/", "29.835, 32.549999999999955, 107-13 , 2013-05-21 , Container , Boarded ,/details\/133\/451\/", "3.28638888889, 103.82305555599999, 106-13 , 2013-05-15 , Tug , Boarded ,/details\/133\/450\/", "1.23333333333, 104.03333333299997, 105-13 , 2013-04-29 , Tug , Boarded ,/details\/133\/449\/", "3.8466666666666667, -77.125, 104-13 , 2013-05-21 , General Cargo , Attempted ,/details\/133\/448\/", "25.5333333333, 57.450000000000045, SUS 005-13 , 2013-05-19 , LPG Tanker , Suspicious ,/details\/133\/447\/", "31.226388888888888, 29.850000000000023, 103-13 , 2013-05-18 , Chemical Tanker , Boarded ,/details\/133\/446\/", "12.2036111111, 44.33333333330006, 102-13 , 2013-05-19 , General Cargo , Attempted ,/details\/133\/445\/", "6.05027777778, 1.283333333330006, 101-13 , 2013-05-17 , Chemical Tanker , Attempted ,/details\/133\/444\/", "5.68527777778, 1.3333333333299606, 100-13 , 2013-05-05 , Chemical Tanker , Boarded ,/details\/133\/443\/", "Unknown, Unknown, 096-13 , 2013-05-05 , Product Tanker , Fired Upon ,/details\/133\/439\/", "3.812578991523159, -77.20213485717773, 099-13 , 2013-05-12 , Bulk Carrier , Boarded ,/details\/133\/442\/", "-3.6833333333333336, 114.45000000000005, 098-13 , 2013-05-12 , Bulk Carrier , Boarded ,/details\/133\/441\/", "6.06666666667, 1.25, 097-13 , 2013-05-09 , Crude Tanker , Attempted ,/details\/133\/440\/", "-2.4683333333333332,-80.06833333333333, 095-13 , 2013-05-05 , Container , Attempted ,/details\/133\/438\/", "4.7175,8.345, 094-13 , 2013-05-07 , Bulk Carrier , Fired Upon ,/details\/133\/437\/", "3.81805555556, 6.683333333329983, 093-13 , 2013-05-04 , Refrigerated Cargo , Fired Upon ,/details\/133\/436\/", "13.6666666667, 48.5, SUS 004-13 , 2013-05-05 , Crude Tanker , Suspicious ,/details\/133\/435\/", "4.03416666667, 6.899999999999977, 092-13 , 2013-05-04 , Container , Fired Upon ,/details\/133\/434\/", "3.7916666666666665, 98.70305555555558, 091-13 , 2013-04-30 , General Cargo , Boarded ,/details\/133\/433\/", "1.6, 105.383333333, 090-13 , 2013-04-24 , Tug , Boarded ,/details\/133\/432\/", "3.8, 4.9500000000000455, 089-13 , 2013-04-26 , Container , Attempted ,/details\/133\/431\/", "3.7866649781442328, 98.68068817986386, 088-13 , 2013-04-27 , Chemical Tanker , Boarded ,/details\/133\/430\/", "2.5166666666666666, 6.833333333333371, 087-13 , 2013-04-22 , Container , Boarded ,/details\/133\/429\/", "4.166666666666667, 5.5, 086-13 , 2013-04-25 , Container , Boarded ,/details\/133\/428\/", "3.86666666667, -77.10000000000002, 085-13 , 2013-01-13 , Chemical Tanker , Boarded ,/details\/133\/427\/", "3.85, 5.668055555555611, 084-13 , 2013-04-24 , Container , Fired Upon ,/details\/133\/426\/", "1.28472222222, 104.83333333299993, 083-13 , 2013-04-24 , Product Tanker , Boarded ,/details\/133\/424\/", "1.3166666666666666, 104.7833333333333, 082-13 , 2013-04-23 , Asphalt\/Bitumen Tanker , Boarded ,/details\/133\/423\/", "-4.73555555556, 11.799999999999955, 081-13 , 2013-04-18 , General Cargo , Attempted ,/details\/133\/422\/", "20.83,107.26, 080-13 , 2013-04-17 , Bulk Carrier , Boarded ,/details\/133\/421\/", "10.366666666666667, -75.55000000000001, 079-13 , 2013-04-16 , Ro-Ro , Boarded ,/details\/133\/420\/", "1.8,6.766666666666667, 078-13 , 2013-04-16 , Crude Tanker , Fired Upon ,/details\/133\/419\/", "-2.3093006882042, -79.93096421559653, 077-13 , 2013-04-15 , Container , Boarded ,/details\/133\/418\/", "-4.56777777778, -81.31694444440001, 076-13 , 2013-04-13 , Crude Tanker , Boarded ,/details\/133\/417\/", "-7.085, 112.64999999999998, 075-13 , 2013-04-13 , Bulk Carrier , Boarded ,/details\/133\/416\/", "8.5, -13.18333333329997, 074-13 , 2013-04-11 , General Cargo , Boarded ,/details\/133\/415\/", "10.566666666666666,107.01666666666666, 073-13 , 2013-04-09 , Bulk Carrier , Boarded ,/details\/133\/413\/", "3.93583333333, 98.73333333329992, 072-13 , 2013-04-06 , Chemical Tanker , Boarded ,/details\/133\/412\/", "17.65, 83.39999999999998, 071-13 , 2013-04-05 , Crude Tanker , Attempted ,/details\/133\/411\/", "0.8686111111111111,44.016666666666666, 070-13 , 2013-04-02 , General Cargo , Fired Upon ,/details\/133\/410\/", "1.70027777778, 101.48333333300002, 069-13 , 2013-04-04 , Crude Tanker , Boarded ,/details\/133\/409\/", "1.72166666667, 101.41666666700007, 068-13 , 2013-04-03 , Chemical Tanker , Attempted ,/details\/133\/407\/", "-1.7177777777777776, 116.65277777777783, 067-13 , 2013-04-03 , Bulk Carrier , Boarded ,/details\/133\/406\/", "3.95083333333, 5.350000000000023, 066-13 , 2013-03-04 , Offshore Supply Ship , Boarded ,/details\/133\/405\/", "3.95083333333, 6.683333333329983, 065-13 , 2013-03-30 , Product Tanker , Fired Upon ,/details\/133\/404\/", "-1.18333333333, 117.26666666699998, 064-13 , 2013-03-29 , Bulk Carrier , Boarded ,/details\/133\/403\/", "11.8666666667, 51.299999999999955, 063-13 , 2013-03-28 , Fishing  , Hijacked ,/details\/133\/402\/", "-1.1416666666666666, 117.25, 062-13 , 2013-03-28 , Bulk Carrier , Boarded ,/details\/133\/401\/", "3.93333333333, 98.78333333329999, 061-13 , 2013-03-27 , Bulk Carrier , Boarded ,/details\/133\/400\/", "31.234444444444445,32.30166666666667, 060-13 , 2013-03-26 , Container , Boarded ,/details\/133\/399\/", "1.71666666667, 101.46666666700003, 059-13 , 2013-03-23 , Chemical Tanker , Boarded ,/details\/133\/398\/", "-5.99333333333, 106.89999999999998, 058-13 , 2013-03-24 , Container , Boarded ,/details\/133\/397\/", "-3.0791666666666666,114.435, 057-13 , 2013-03-26 , Bulk Carrier , Boarded ,/details\/133\/396\/", "1.71111111111, 101.45000000000005, 056-13 , 2013-03-25 , General Cargo , Boarded ,/details\/133\/395\/", "5.303333333333334,4.016666666666667, 055-13 , 2013-03-24 , General Cargo , Boarded ,/details\/133\/394\/", "-6.833571740864381, 39.293924047682026, 054-13 , 2013-03-24 , Container , Boarded ,/details\/133\/393\/", "22.25, 91.73333333329992, 053-13 , 2013-03-22 , Product Tanker , Boarded ,/details\/133\/392\/", "-7.0841666666666665, 112.65666666666664, 052-13 , 2013-03-21 , Bulk Carrier , Boarded ,/details\/133\/391\/", "11.133333333333332,-74.26666666666666, 051-13 , 2013-03-16 , Bulk Carrier , Boarded ,/details\/133\/390\/", "13.65,50.80694444444445, 050-13 , 2013-03-14 , Crude Tanker , Attempted ,/details\/133\/388\/", "-1.6672222222222221,116.65, 049-13 , 2013-03-14 , Bulk Carrier , Boarded ,/details\/133\/387\/", "3.9344444444444444,98.74333333333334, 048-13 , 2013-03-12 , Chemical Tanker , Boarded ,/details\/133\/386\/", "14.284444444444444,49.85, 047-13 , 2013-03-04 , Crude Tanker , Attempted ,/details\/133\/385\/", "-3.56, 114.43333333300006, 046-13 , 2013-03-04 , Bulk Carrier , Boarded ,/details\/133\/384\/", "1.70527777778, 101.48333333300002, 045-13 , 2013-02-27 , Chemical Tanker , Boarded ,/details\/133\/383\/", "-4.56777777778, -81.30222222219998, 044-13 , 2013-02-27 , Crude Tanker , Attempted ,/details\/133\/382\/", "10.303611111111111,-75.52222222222222, 043-13 , 2013-02-24 , LPG Tanker , Boarded ,/details\/133\/380\/", "3.85, 5.9500000000000455, 042-13 , 2013-02-22 , General Cargo , Fired Upon ,/details\/133\/379\/", "-5.566666666666666,104.58333333333333, 041-13 , 2013-02-20 , LPG Tanker , Boarded ,/details\/133\/378\/", "22.1836111111, 91.76666666670007, 040-13 , 2013-02-18 , Product Tanker , Boarded ,/details\/133\/377\/", "-7.15,112.66666666666667, 039-13 , 2013-02-20 , Bulk Carrier , Boarded ,/details\/133\/376\/", "-1.38416666667, 116.93333333300006, 038-13 , 2013-02-20 , Chemical Tanker , Boarded ,/details\/133\/375\/", "3.6799999999999997,5.883333333333333, 037-13 , 2013-02-07 , Offshore Supply Ship , Hijacked ,/details\/133\/374\/", "0.13583333333333333, 106.30250000000001, 036-13 , 2013-02-18 , Container , Boarded ,/details\/133\/373\/", "7.23444444444, 52.28333333329999, 035-13 , 2013-02-18 , General Cargo , Fired Upon ,/details\/133\/372\/", "6.45, 3.3833333333333257, 034-13 , 2013-02-17 , Bulk Carrier , Boarded ,/details\/133\/371\/", "3.951111111111111, 5.333333333333371, 033-13 , 2013-02-17 , Offshore Supply Ship , Boarded ,/details\/133\/370\/", "1.7008333333333332, 101.45000000000004, 032-13 , 2013-02-18 , Chemical Tanker , Boarded ,/details\/133\/369\/", "9.9, 76.13333333330001, 031-13 , 2013-02-14 , Chemical Tanker , Boarded ,/details\/133\/368\/", "3.5652777777777777,6.594166666666666, 030-13 , 2013-02-10 , Offshore Supply Ship , Boarded ,/details\/133\/367\/", "22.263333333333332,91.71333333333334, 029-13 , 2013-02-15 , Bulk Carrier , Boarded ,/details\/133\/366\/", "20.6236111111, 106.872777778, 028-13 , 2013-02-14 , Container , Boarded ,/details\/133\/365\/", "1.101388888888889,103.6, 026-13 , 2013-02-13 , Crude Tanker , Boarded ,/details\/133\/364\/", "-1.2858333333333333,116.78333333333333, 027-13 , 2013-02-12 , Chemical Tanker , Boarded ,/details\/133\/363\/", "1.71, 101.45000000000004, 025-13 , 2013-02-12 , Bulk Carrier , Boarded ,/details\/133\/362\/", "4.11888888889, 6.866666666669971, 024-13 , 2013-02-11 , General Cargo , Fired Upon ,/details\/133\/361\/", "2.78333333333, 5.80166666667003, 023-13 , 2013-02-07 , General Cargo , Boarded ,/details\/133\/360\/", "-1.68555555556, 116.63499999999999, 022-13 , 2013-02-06 , Bulk Carrier , Boarded ,/details\/133\/359\/", "14.5522222222, 120.89999999999998, 021-13 , 2012-01-31 , General Cargo , Boarded ,/details\/133\/358\/", "4.12722222222, -3.8999999999999772, 020-13 , 2013-02-03 , Crude Tanker , Hijacked ,/details\/133\/357\/", "6.321111111111111,3.4, 019-13 , 2013-02-04 , Chemical Tanker , Fired Upon ,/details\/133\/356\/", "3.9183333333333334, 98.79999999999995, 018-13 , 2013-02-02 , Chemical Tanker , Attempted ,/details\/133\/355\/", "3.77166666667, 5.816666666670017, 017-13 , 2013-01-31 , Crude Tanker , Fired Upon ,/details\/133\/354\/", "20.8836111111, -16.98527777779998, 016-13 , 2013-01-31 , Refrigerated Cargo , Boarded ,/details\/133\/353\/", "2.1425, 108.75, 015-13 , 2013-01-24 , Tug and Barge , Boarded ,/details\/133\/352\/", "20.943333333333335, 88.16694444444443, 014-13 , 2013-01-29 , Product Tanker , Boarded ,/details\/133\/351\/", "17.018055555555555, 82.39999999999998, 013-13 , 2013-01-27 , Chemical Tanker , Boarded ,/details\/133\/350\/", "-4.573333333333333,-81.275, 012-13 , 2013-01-23 , Crude Tanker , Boarded ,/details\/133\/349\/", "1.70083333333, 101.48333333300002, 011-13 , 2013-01-22 , Chemical Tanker , Boarded ,/details\/133\/348\/", "-1.3666666666666667, 116.9333333333334, 010-13 , 2013-01-17 , Crude Tanker , Boarded ,/details\/133\/347\/", "5.196111111111112, -3.9563888888889096, 009-13 , 2013-01-16 , Product Tanker , Hijacked ,/details\/133\/346\/", "22.28472222222222, 91.7166666666667, 008-13 , 2013-01-16 , Bulk Carrier , Boarded ,/details\/133\/345\/", "-4.71916666667, 11.766666666699962, 007-13 , 2013-01-15 , Container , Boarded ,/details\/133\/344\/", "-1.18361111111, 116.76666666699998, 006-13 , 2013-01-12 , Bulk Carrier , Boarded ,/details\/133\/343\/", "1.1847222222222222, 103.61888888888893, 005-13 , 2013-01-08 , Tug , Boarded ,/details\/133\/342\/", "6.750555555555556,-58.18333333333333, 004-13 , 2013-01-09 , LPG Tanker , Boarded ,/details\/133\/341\/", "3.11722222222, 51.85000000000002, 003-13 , 2013-01-05 , Container , Fired Upon ,/details\/133\/339\/", "-1.2650362815758927, 116.81155974103558, 002-13 , 2013-01-04 , Chemical Tanker , Boarded ,/details\/133\/338\/", "22.8166666667, 70.04999999999995, 001-13 , 2013-01-03 , Bulk Carrier , Boarded ,/details\/133\/337\/"]
count = pirateData.length

# Creation of excel workbook and worksheet. This section adds headers to each
# column and names the worksheet
# sheet[row,col]

book = Spreadsheet::Workbook.new
sheet = book.create_worksheet
sheet.name = "Pirate Incidents up to 2013"
sheet[0,0] = 'Latitude'
sheet[0,1] = 'Longitude'
sheet[0,2] = 'Attack ID'
sheet[0,3] = 'Date'
sheet[0,4] = 'Vessel Type'
sheet[0,5] = 'Status'
sheet[0,6] = 'Description'

# Populate spreadsheet with pirateData and summaries from pageURL

for i in 1...count + 1
	eventData = pirateData[i - 1].split(',')
	lat = eventData[0]
	long = eventData[1]
	attackID = eventData[2]
	date = DateTime.strptime(eventData[3].strip, " %Y-%m-%d").iso8601
	vesselType = eventData[4]
	status = eventData[5]
	urlExtension = eventData[6].strip
	
	pageURL = baseURL + urlExtension
	page = Nokogiri::HTML(open(pageURL))
	text = page.css('div#jos_fabrik_icc_ccs_piracymap2012___narrations_ro').inner_text	

	sheet[i,0] = lat.strip
	sheet[i,1] = long.strip
	sheet[i,2] = attackID.strip
	sheet[i,3] = date
	sheet[i,4] = vesselType.strip
	sheet[i,5] = status.strip
	sheet[i,6] = text.to_s
	
	puts "#{count - i} more to go."
end

book.write Dir.pwd + "//Pirate Information.xls"
