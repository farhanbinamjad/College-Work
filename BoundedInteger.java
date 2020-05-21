/**
* Intermediate Computing 
*
* Homework #3 Bounded Integer Class
*
* @Farhan Bin Amjad - CS 2530 - binamjf@uni.edu
*
* @version 1 - 2018-09-29
*
*/

public class BoundedInteger
{ 
   private int lowerbound;
   private int upperbound;
   private int currentvalue;
   

   public BoundedInteger(int lowerbound, int upperbound)
   {
      this.lowerbound = lowerbound;
      this.upperbound = upperbound;
      this.currentvalue = lowerbound;
   }
   
   public BoundedInteger(int lowerbound, int upperbound, int currentvalue)
   {
      this.lowerbound = lowerbound;
      this.upperbound = upperbound;
      this.currentvalue = currentvalue;     
   }
   
   public BoundedInteger() throws Exception
   {
      if (currentvalue > upperbound && currentvalue < lowerbound)
      {
         throw new Exception("Current Value needs to be in between lowerbound and upperbound");
      }
   }

   public int getValue()
   {
      return currentvalue;
   }

   public int getLowerLimit()
   {
      return lowerbound;
   }

   public int getUpperLimit()
   {
      return upperbound;
   }
   
   public boolean setvalue(int newvalue)
   {
      int temp = currentvalue;
      if (newvalue >= lowerbound && newvalue <= upperbound)
      {
         currentvalue = newvalue;
         return true;
      }
      else
      {
         return false;
      }
   }

   public String toString()
   {
      String newString = "BoundedInteger [lower= " + lowerbound + " , upper=" + upperbound + " ,value=" + currentvalue+ "]";
      return newString;
      
   }

   public void add(int numbertoadd)
   {
      if (numbertoadd < 0)
      {
      
         if (isLegal(currentvalue - Math.abs(numbertoadd)))
         {
            currentvalue = currentvalue - Math.abs(numbertoadd);     
         }   
         else
         {
            currentvalue = (upperbound +1) -(Math.abs(numbertoadd) - (currentvalue - lowerbound));
         }
      }
      else
      {
         if(isLegal(currentvalue + numbertoadd))
            
         {
            currentvalue = currentvalue + numbertoadd;
         }
         else
         {
            int temp = currentvalue;
            temp += numbertoadd;
            int index = (upperbound + 1) - lowerbound; 
            
            while (temp > upperbound)
            {
               temp = temp - index;
               
            }
            currentvalue = temp;
           
         }
          
      }
      
   }

     
   public void subtract(int numbertosubtract)
   {
      if (numbertosubtract < 0)
      {
      
         if (isLegal(currentvalue + Math.abs(numbertosubtract)))
         {
            currentvalue = currentvalue + Math.abs(numbertosubtract);     
         }   
         else
         {
         
            int temp = currentvalue;
            temp += Math.abs(numbertosubtract);
            int index = (upperbound + 1) - lowerbound; 
            
            while (temp > upperbound)
            {
               temp = temp - index;
               
            }
            currentvalue = temp;

         }
      }
      else
      {
         if(isLegal(currentvalue - numbertosubtract))
            
         {
            currentvalue = currentvalue - numbertosubtract;
         }
         else
         {
            int temp = currentvalue;
            temp -= numbertosubtract;
            int index = (upperbound + 1) - lowerbound; 
            
            while (temp < lowerbound)
            {
               temp = temp + index;
               
            }
            currentvalue = temp;
           
         }
          
      }
      
   }
   
   public void increment()
   {
      currentvalue++;
      int temp = currentvalue;
      if (currentvalue > upperbound)
      {
         currentvalue = lowerbound;
      }
      else
      {
         currentvalue = temp;
      }
   
   }

   public void decrement()
   {
      currentvalue--;
      int temp = currentvalue;
      if (currentvalue < lowerbound)
      {
         currentvalue = upperbound ;
      }
      else
      {
         currentvalue = temp;
      }
   }
   
   public boolean equals(BoundedInteger other)
   {
      if (other.lowerbound == this.lowerbound && other.upperbound == this.upperbound && other.currentvalue == this.currentvalue)
      {
         return true;
      }
      else
      {
         return false;
      }
   }

   public boolean equivalentValue(BoundedInteger other)
   {
      if (other.currentvalue == this.currentvalue)
      {
         return true;
      }
      else
      {
         return false;
      }
   
   }

   public boolean equivalentLowerLimit(BoundedInteger other)
   {
      if (other.lowerbound == this.lowerbound)
      {
         return true;
      }
      else
      {
         return false;
      }
   
   }

   public boolean equivalentUpperLimit(BoundedInteger other)
   {
      if (other.upperbound == this.upperbound)
      {
         return true;
      }
      else
      {
         return false;
      }
   
   }


   public boolean isLegal(int value)
   {
      if (value <= upperbound && value >= lowerbound)
      {
         return true;
      }
      else
      {
         return false;
      }
   
      
   }



}
