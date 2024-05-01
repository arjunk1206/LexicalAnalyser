%{
    #include<stdio.h>
    #include<stdlib.h>
    #include<string.h>
    #include<stdbool.h>
    #include<math.h>

    #define MAX_STUD_ID_LENGTH 30
    #define MAX_COURSE_ID_LENGTH 30
    #define MAX_RECORD_COUNT 100

    int record_count = 0;
    int comment_count = 0;
    float cgpa = 0;
    bool valid_id = false;
    int current_grade = 0;
    int current_unit = 0;
    int curr_record_index = 0;
    int curr_course_index = 0;
    typedef struct 
    {
        char studID[MAX_STUD_ID_LENGTH];
        int course[30][2];
        char course_name[30][MAX_COURSE_ID_LENGTH];
        int course_count;
    } student;

    student studentlist[MAX_RECORD_COUNT];

    char inputstudID[MAX_COURSE_ID_LENGTH];
    int distinct_course_count = 0;
    float CGPA = 0;
    float numerator = 0;
    float denominator = 0;
    char counted_courses[30][MAX_COURSE_ID_LENGTH];

    FILE *fp;
    

%}

%x STUDENTID
%x STUDENTIDFOUND
%x COURSEIDSTART
%x COURSEUNIT 
%x COURSEGRADE
%x COMMENT
%x COURSEIDEND
%x STUDENTIDNOTFOUND

%%
\/\/.*[\n] {
    comment_count++;
    }

<COMMENT>. {}
<COMMENT>[\n] {
BEGIN(INITIAL);}

[^$]*\/\/.* {comment_count++;
    }
$[' '\t]* {BEGIN(STUDENTID);}

<STUDENTID>[A-Z]+[0-9]+ {
        strcpy(studentlist[curr_record_index].studID,yytext);
        studentlist[curr_record_index].course_count = 0;
        BEGIN(STUDENTIDFOUND);

    }
<STUDENTID>[<][A-Z]+[0-9]+ {
        BEGIN(STUDENTIDNOTFOUND);
    }
<STUDENTID>[A-Z]+[' '\t]* {BEGIN(STUDENTIDNOTFOUND);}
<STUDENTID>[0-9]+[A-Z]+[' '\t]* {BEGIN(STUDENTIDNOTFOUND);}
<STUDENTID>[a-z]+[0-9]+[' '\t]* {BEGIN(STUDENTIDNOTFOUND);}
<STUDENTID>\/\/.*[\n] {
     comment_count++;
     BEGIN(COMMENT);
    }
<STUDENTIDFOUND>[' '\t]* {}
<STUDENTIDFOUND>[\n] {BEGIN(INITIAL);}
<STUDENTIDFOUND>[<] {
    unput('<');
    BEGIN(COURSEIDSTART);}

<STUDENTIDFOUND>\/\/.* {
     comment_count++;
    
     BEGIN(COMMENT);
    }

<STUDENTIDNOTFOUND>.*\/\/ {
     comment_count++;
     BEGIN(COMMENT);
    }


<COURSEIDSTART>[' '\t]* {}
<COURSEIDSTART>"//" {
    comment_count++;
    BEGIN(COMMENT);}
<COURSEIDSTART>< {};
<COURSEIDSTART>[A-Z]+[0-9]+[' '\t]+ {
    strcpy(studentlist[curr_record_index].course_name[curr_course_index],yytext);
    BEGIN(COURSEUNIT);
}

<COURSEUNIT>[2-4][' '\t]+ {
    int units = atoi(yytext);
    studentlist[curr_record_index].course[curr_course_index][0] = units;
    BEGIN(COURSEGRADE);
}
<COURSEUNIT>[' '\t]* {}
<COURSEUNIT>"//" {
    comment_count++;
    // record_count--;
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    //studentlist[curr_record_index].course_count--;
    // printf("Comment Detected\n");
    BEGIN(COMMENT);
}
<COURSEUNIT>[0-1|5-9]+ {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    printf("INVALID COURSE UNIT, NOT A COURSE TUPLE\n");
    BEGIN(STUDENTIDFOUND);
}
<COURSEUNIT>[A-Z]+ {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    BEGIN(STUDENTIDFOUND);
}
<COURSEUNIT>[\n] {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    BEGIN(INITIAL);
}
<COURSEUNIT>">" {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    studentlist[curr_record_index].course[curr_course_index][1] = 0;
    BEGIN(COURSEIDEND);
}


<COURSEGRADE>[A-C][\-]? {
    int point = 0;
    char letter = yytext[0];
    
    char symbol = yytext[1];
    if(letter == 'A' && symbol != '-' && symbol!= 'B' && symbol!='C' && symbol!='A' )
    {
        point = 10;
    }
    else if(letter == 'A' && symbol == '-' && symbol!= 'B' && symbol!='C' && symbol!='A')
    {
        point = 8;
    }
    else if(letter == 'B' && symbol != '-' && symbol!= 'B' && symbol!='C' && symbol!='A')
    {
        point = 6;
    }
    else if(letter == 'B' && symbol == '-' && symbol!= 'B' && symbol!='C' && symbol!='A')
    {
        point = 4;
    }
    else if(letter == 'C' && (symbol != '-' && symbol!= 'B' && symbol!='C' && symbol!='A'))
    {
        point = 2;
    }
    else
    {
        studentlist[curr_record_index].course[curr_course_index][0] = 0;
        studentlist[curr_record_index].course[curr_course_index][1] = 0;
        BEGIN(STUDENTIDFOUND);
    }
    studentlist[curr_record_index].course[curr_course_index][1] = point;
    studentlist[curr_record_index].course_count++;
    BEGIN(COURSEIDEND);
}
<COURSEGRADE>[' '\t]* {}

<COURSEGRADE>"//" {
    comment_count++;
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    studentlist[curr_record_index].course[curr_course_index][1] = 0;
    BEGIN(COMMENT);
}
<COURSEGRADE>">" {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    studentlist[curr_record_index].course[curr_course_index][1] = 0;
    BEGIN(COURSEIDEND);
}

<COURSEIDEND>[A-Z]+ {
    studentlist[curr_record_index].course[curr_course_index][0] = 0;
    studentlist[curr_record_index].course[curr_course_index][1] = 0;
    BEGIN(COURSEIDEND);

}
<COURSEIDEND>[' '\t]* {}
<COURSEIDEND>[' '\t]*">" {}
<COURSEIDEND>"//" {
    comment_count++;
    record_count++;
    studentlist[curr_record_index].course_count++;
    curr_record_index++;
    curr_course_index = 0;
    BEGIN(COMMENT);}
<COURSEIDEND>"<" {
    studentlist[curr_record_index].course_count++;
    curr_course_index++;
    unput('<');
    BEGIN(STUDENTIDFOUND);
    }

<COURSEIDEND>[$] {
    record_count++;
    studentlist[curr_record_index].course_count++;
    curr_record_index++;
    curr_course_index = 0;
    unput('$');
    BEGIN(STUDENTID);
}
<COURSEIDEND>[\n] {
    record_count++;
    studentlist[curr_record_index].course_count++;
    curr_record_index++;
    curr_course_index = 0;
    BEGIN(INITIAL);
}

%%


int main()
{
    fp = fopen("input.txt","r");
    fscanf(fp,"%s",inputstudID);
    fclose(fp);

    yyin = fopen("data.txt","r");
    yylex();
    
    for(int i = record_count - 1; i >= 0; i--)
    {
        if(!strcmp(inputstudID,studentlist[i].studID))
        {
            
            for(int j = 0; j < studentlist[i].course_count; j++)
            {
                
                
                if(studentlist[i].course[j][0] != 0 && studentlist[i].course[j][1] != 0)
                {
                    if(distinct_course_count == 0)
                    {
                        strcpy(counted_courses[distinct_course_count],studentlist[i].course_name[j]);
                        distinct_course_count++;
                        numerator += studentlist[i].course[j][0] * studentlist[i].course[j][1];
                        denominator+= studentlist[i].course[j][0];
                    }
                    else 
                    {
                        bool counted = false;
                        for(int k = 0; k < distinct_course_count; k++)
                        {
                            if(!strcmp(studentlist[i].course_name[j],counted_courses[k]))
                            {
                                counted = true;
                                break;
                            }
                        }
                        if(counted == false)
                        {
        
                        strcpy(counted_courses[distinct_course_count],studentlist[i].course_name[j]);
                        distinct_course_count++;
                        printf("%d %d",studentlist[i].course[j][0] * studentlist[i].course[j][1],studentlist[i].course[j][0]);
                        numerator += studentlist[i].course[j][0] * studentlist[i].course[j][1];
                        denominator+= studentlist[i].course[j][0];
                        }
                    }
                }
            }
            
        }
    }

    CGPA = numerator/denominator;

    printf("Distinct Courses = %d\n", distinct_course_count);
    for(int i = 0; i < distinct_course_count; i++)
    {
        printf("Course %d : %s\n", i, counted_courses[i]);
    }

    fp = fopen("output.txt","w+");
    fprintf(fp,"@%d@%d@%d@%d#",record_count,comment_count,distinct_course_count,(int)round(CGPA*100));
    fclose(fp);
    return 0;

}


