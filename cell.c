#include <stdio.h>

extern int cells_array[];
extern int WorldLength,WorldWidth;

int cell(int x,int y){
    int state = cells_array[x*WorldWidth + y];
    int num_of_alive_neighbors = 0;
    int location;
    /*check up*/
    location = x - 1;
    if(location < 0)
        location = (location+WorldLength)*WorldWidth + y;
    else
        location = location*WorldWidth + y;
    
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check down*/
    location = ((x + 1)%WorldLength)*WorldWidth + y;
    
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check left*/
    location = y - 1;
    if(location < 0)
        location = (location+WorldWidth) + x*WorldWidth;
    else
        location = location + x*WorldWidth;
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check right*/
    location = x*WorldWidth + (y + 1)%WorldWidth;
    
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check top left*/
    if(y < 1 && x < 1)
        location = y+WorldWidth-1 + (x-1+WorldLength)*WorldWidth;
    else if(y < 1 && x >= 1)
        location = y+WorldWidth-1 + (x-1)*WorldWidth;
    else if(y >= 1 && x < 1)
        location = y - 1 + (x-1+WorldLength)*WorldWidth;
    else
        location = (x-1)*WorldWidth + y - 1;
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check top right*/
    
    if(x < 1)
        location = (y + 1)%WorldWidth + (x-1+WorldLength)*WorldWidth;
    else
        location = (x-1)*WorldWidth + (y + 1)%WorldWidth;
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check bottom left*/
    if(y < 1)
        location = y-1+WorldWidth + ((x+1)%WorldLength)*WorldWidth;
    else
        location = ((x+1)%WorldLength)*WorldWidth + y - 1;
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
    /*check bottom right*/
    
    location = ((x+1)%WorldLength)*WorldWidth + (y + 1)%WorldWidth;
    if(cells_array[location] >= 1)
        num_of_alive_neighbors++;
        
    if (state == 0 && num_of_alive_neighbors == 3)
        state = 1;
    else if (state > 0 && (num_of_alive_neighbors==3 || num_of_alive_neighbors == 2)){
        if(state < 9)
            state += 1;
    }
    else
        state = 0;
    return state;
}