# read CSV file
def read_csv (file,
              delimiter=',', header_lines=1, label_line=1, type='',
              encoding='utf-8-sig', output=''):
    import csv
    result = []
    label = []
    with open(file, 'r', encoding=encoding) as f:
        reader = csv.reader(f,delimiter=delimiter)
        for i,row in enumerate(reader):
            if label_line==1:
                label_line = 0
                label = row
            if i>=(header_lines):
                values = []
                for word in row:
                    if len(word)>0: #length(string)
                        s = word.strip()
                        try:
                            if type=='int':
                                s = int(word)
                            if type=='long':
                                s = long(word)
                            if type=='float':
                                s = float(word)
                        except:
                            pass
                        values.append(s)
                result.append(values)
    if output=='extra':
        return result, label
    else:
        return result


# tranpose of a list matrix
def transpose(M):
    return [list(i) for i in zip(*M)]


# substract lists
def substract_lists(lista,listb):
    result = []
    for la,lb in zip(lista,listb):
        r = []
        for a,b in zip(la,lb):
            r.append(a-b)
        result.append(r)
    return result



# export list matrix to CSV file
def write_csv(M,
               file='lists.csv', post='',pre='', delimiter=',',
               newline='\n', replace_from=',', replace_to=';', mode='w'):
    with open(file, mode, newline='\n') as cfile:
        if M is not None:
            for row in M:
                if type(row) is not list:
                    cfile.write(pre+str(row).replace(replace_from,replace_to)+post+delimiter)
                else:
                    for i,col in enumerate(row):
                        if type(col) is not list:
                            if i<(len(row)-1):
                                cfile.write(pre+str(col).replace(replace_from,replace_to)+post+delimiter)
                            else:
                                cfile.write(pre+str(col).replace(replace_from,replace_to)+post)
                        else:
                            for j,c in enumerate(col):
                                if i<(len(col)-1):
                                    cfile.write(pre+str(c).replace(replace_from,replace_to)+post+delimiter)
                                else:
                                    cfile.write(pre+str(c).replace(replace_from,replace_to)+post)
                cfile.write(newline)
    cfile.close()
    

# convert float number to string
def numstr(number,digit=1):
    power = 10**digit
    return str(round(number*power)/power)
