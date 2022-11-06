#!/bin/bash

display_menu(){

	echo -e "\nMENU"
	echo -e "\n1.First Come First Serve [FCFS]"
	echo "2.Shortest Job First [SJF Non-Preemptive]"
	echo "3.Shortest Job First [SJF Preemptive]"
	echo "4.Non-Preemptive Priority Scheduling"
	echo "5.Round Robin Scheduling"
	echo "6.Quit"
}

# pid - Array to store process id of processes.
# at - Array to store arrival time
# bt - Array to store burst time
# pr - Array to store priority of processes
# cpt - Array to store completion time of processes
# wt - Array to store waiting time of processes
# tat - Array to store turnaround time of processes
# rt - Array to store remaining burst time of processes in preemptive algorithms

# Function to take user input depending on the algorithm to be executed.

take_input(){

echo -e "\nEnter the number of processes"
read n

if [[ $1 -eq 1 ]];then
	echo "Enter the PID,Arrival time,Burst time,Priority for the processes"
	for ((i=0;i<$n;i++))
	do
		read pid[$i] at[$i] bt[$i] pr[$i]
	done
else
	echo "Enter the PID,Arrival time,Burst time for the processes"
	for ((i=0;i<$n;i++))
	do
		read pid[$i] at[$i] bt[$i]
	done
fi
}

# Function to sort the arrival times of processes.

sort_at(){

for ((i=0;i<(($n-1));i++))
do 
	for ((j=0;j<(($n-1-$i));j++))
	do
		if [ ${at[$j]} -gt ${at[((j+1))]} ];then
	# Sorting the array of arrival times
			((t=at[j]))
			((at[j]=at[((j+1))]))
			((at[((j+1))]=t))
	# Changing the positions of the corresponding Burst time
			((t=bt[j]))
			((bt[j]=bt[((j+1))]))
			((bt[((j+1))]=t))
	# Changing the positions of the corresponding PID
			((t=pid[j]))
			((pid[j]=pid[((j+1))]))
			((pid[((j+1))]=t))	

			if [[ $1 -eq 1 ]];then
				# Changing the positions of the corresponding priorities
				((t=pr[j]))
				((pr[j]=pr[((j+1))]))
				((pr[((j+1))]=t))
			fi
		fi
	done
done
}

fcfs()
{
	wt[0]=0		# Waiting time of first arrived process is 0
	st[0]=0		# Service time of first arrived process is 0

	# Waiting time:
	for ((i=1;i<n;i++))
	do
		((st[$i]=((st[((i-1))]+bt[((i-1))]))))  #Service time means the amount of time after which a process can start execution. 
		((wt[$i]=((st[i]-at[i]))))				#It is summation of burst time of previous processes
	done

	# Turnaround time:
	for ((i=0;i<n;i++))
	do
		((tat[i]=((bt[i]+wt[i]))))
		((cpt[i]=((st[i]+bt[i])))) 
	done

}


# Used to swap the completed processes to the top of the array in non-preemptive algorithms
swap(){

	i=$1
	val=$2
	is_priority=$3

	# Swapping the pid column
	temp=${pid[$i]}
	pid[$i]=${pid[$val]}
	pid[$val]=$temp

	# Swapping the at column
	temp=${at[$i]}
	at[$i]=${at[$val]}
	at[$val]=$temp

	# Swapping the bt column
	temp=${bt[$i]}
	bt[$i]=${bt[$val]}
	bt[$val]=$temp

	if [[ $is_priority -eq 1 ]];then
	# Swapping the pr column
		temp=${pr[$i]}
		pr[$i]=${pr[$val]}
		pr[$val]=$temp
	fi
}

# Function to check if the arrival time of all processes is 0
is_at_zero(){

	for((i=0;i<n;i++))
	do
		if [[ ${at[$i]} -ne 0 ]];then 
			return 1
		fi
	done
	return 0
}

# Function to find the minimum burst time for SJF if the arrival time of all processes is 0.
find_min_bt(){

	least_burst=${bt[0]}
	k=0
	for((i=1;i<n;i++))
	do
		if [[ ${bt[$i]} -lt least_burst ]];then
			least_burst=${bt[$i]}
			k=$i
		fi
	done
}

# Function to find the maximum priority for Priority Scheduling if the arrival time of all processes is 0.
# Lower the priority number, the higher is the priority of the process. 
find_max_pr(){

	max_priority=${pr[0]}
	k=0

	for((i=1;i<n;i++))
	do
		if [[ ${pr[$i]} -lt max_priority ]];then
			max_priority=${pr[$i]}
			k=$i
		fi
	done
}

# Algorithm for Non-preemptive SJF
sjf_n(){

	is_at_zero			
	IS_AT_ZERO=$?			# Storing the exit status of is_at_zero function

	if [[ IS_AT_ZERO -eq 0 ]];then  # Arrival time of all processes is 0 
		find_min_bt					# Process with min burst time to be selected first - process k
		cpt[0]=${bt[k]}				
		tat[0]=${bt[k]}
		swap 0 $k					# Swaps the process at index k with index 0 as it has been completed first.
	else							# Arrival time of all processes is different. Select the process that arrives first after sorting the arrival times.
		cpt[0]=${bt[0]}				
		tat[0]=${bt[0]}
	fi

	wt[0]=0							

	# Finding the process with the next shortest burst time among the remaining processes.
	for((i=1;i<n;i++))
	do
		least_burst=${bt[$i]} 
		val=$i

		for((j=((i+1));j<n;j++))
		do
			if [[ ${cpt[((i-1))]} -ge ${at[$j]} ]] && [[ $least_burst -gt ${bt[$j]} ]];then
				least_burst=${bt[$j]}
				val=$j
			fi
		done

		swap $i $val 				# Swaps the process at index val with index i as it has been completed in that sequence.
		
		((cpt[i]=((cpt[((i-1))]+bt[i]))))
		((tat[i]=((cpt[i]-at[i]))))
		((wt[i]=((tat[i]-bt[i]))))
	done
}

# Similar to Non-preemptive SJF
priority_scheduling(){

	is_at_zero
	IS_AT_ZERO=$?

	if [[ IS_AT_ZERO -eq 0 ]]
	then
		find_max_pr 
		cpt[0]=${bt[k]}
		tat[0]=${bt[k]}
		swap 0 $k 1
	else
		cpt[0]=${bt[0]}
		tat[0]=${bt[0]}
	fi

	wt[0]=0

	for((i=1;i<n;i++))
	do
		max_priority=${pr[$i]}
		val=$i

		for((j=((i+1));j<n;j++))
		do
			if [[ ${cpt[((i-1))]} -ge ${at[$j]} ]] && [[ $max_priority -gt ${pr[$j]} ]]
			then
				max_priority=${pr[$j]}
				val=$j
			fi
		done

		swap $i $val 1
		
		((cpt[i]=((cpt[((i-1))]+bt[i]))))
		((tat[i]=((cpt[i]-at[i]))))
		((wt[i]=((tat[i]-bt[i]))))

	done

}

# Algorithm for preemptive SJF
# Checks all processes at each time unit to find the shortest process and preempt the current one.
sjf_p(){

	for((i=0;i<n;i++))
	do 
		rt[$i]=${bt[$i]}	#Initially, remaining time is equal to burst time.
	done

	complete=0 			# No. of processes completed
	t=0        			# Current time 
	mint=10000			# Shortest remaining time of processes.
	t_old=0				# The time till which the previous process executed. (for gantt chart)

	while [[ $complete -ne $n ]]
	do
		shortest_prev=${pid[$shortest]} 	# Storing the pid of the currently executing process before it gets changed (for gantt chart)
		
		# Finding the process with shortest remaining time among the other processes.
		for((i=0;i<n;i++))
		do
			if [ ${at[$i]} -le $t ] && [ ${rt[$i]} -lt $mint ] && [ ${rt[$i]} -gt 0 ];then
				mint=${rt[$i]}
				shortest=$i
				flag=1
			fi
		done
		
		# If the process currently in execution gets preempted, plot its gantt chart.
		if [[ $flag -eq 1 ]]
		then
			gant_chart_sjfp
			flag=0
		fi

		((rt[shortest]-=1))		# Reduce the remaining time of the process currently in execution by 1 unit 
		mint=${rt[$shortest]}	# Update the value of mint.

		if [ ${rt[$shortest]} -eq 0  ] ;then    # If the rt is 0, the process gets completed. Set it to a max value for the other process to get selected.
			mint=10000

			((complete+=1))
		
			((cpt[shortest]=t+1))
			((tat[shortest]=cpt[shortest]-at[shortest]))
			((wt[shortest]=tat[shortest]-bt[shortest]))
		fi

		if [[ $complete -eq $n ]];then		# Handling the edge case of printing the gantt chart 
			((t+=1))
			gant_chart_sjfp
			continue
		fi

		((t+=1))	# Increment the current time by 1 unit. 
	done			
}

# Similar to SJF Preemptive Algorithm
round_robin(){

	for((i=0;i<n;i++))
	do 
		rt[$i]=${bt[$i]}	
	done

	complete=0 			
	t=0        		
	i=0
	t_old=0

	while [[ $complete -ne $n ]]
	do
		if [[ ${at[$i]} -le $t ]] && [[ ${rt[$i]} -gt 0 ]];then
			if [ ${rt[$i]} -gt $time_q ];then
				((t+=time_q))
				((rt[i]-=time_q))
			else
				((t+=rt[i]))
				((rt[i]=0))
				((complete+=1))
			
				((cpt[i]=t))
				((tat[i]=cpt[i]-at[i]))
				((wt[i]=tat[i]-bt[i]))
			fi
			flag=1
		fi
		
		if [[ $flag -eq 1 ]]
		then
			shortest_prev=${pid[$i]}
			gant_chart_sjfp
			flag=0
		fi
		((i=(i+1)%n))           # Traversing through the array in a circular fashion.
	done			
}

# Function to print the information and calculate the average waiting and turnaround time.
find_avgtime(){
	
	total_tat=0
	total_wt=0
	echo
	echo -e "\nProcesses Arrival_time Burst_time Completion_time Waiting_time Turnaround_time"
	for((i=0;i<n;i++))
	do
		((total_wt+=wt[i]))
		((total_tat+=tat[i]))
		echo -e "${pid[i]}\t\t${at[i]}\t  ${bt[i]} \t        ${cpt[i]} \t      ${wt[i]}       \t   ${tat[i]}"
	done

	echo -e "Average waiting time: \c"
	echo "scale=2; $total_wt/$n"|bc
	echo -e "Average turnaround time: \c"
	echo "scale=2; $total_tat/$n"|bc
}

gant_chart_sjfp()
{	
	for((j=1;j<=((t-t_old));j++))
	do
		((j%5)) && echo -e "* \c" || echo -e "# \c"
	done
	t_old=$t

	if [[ $t -ne 0 ]]
	then
		echo -e "P$shortest_prev \c"
	fi
}

gant_chart(){
	echo -e "\n\t\t\tGANTT CHART\t\t"
	echo "* represents 1 time unit each and # comes at intervals of 5 time units"
	echo 
	for((i=0;i<n;i++))
	do
		for((j=1;j<=bt[i];j++))
		do
			((j%5)) && echo -e "* \c" || echo -e "# \c"
		done
		echo -e "P${pid[i]} \c"
	done	
}

FCFS(){

take_input
sort_at
fcfs
find_avgtime
gant_chart
echo -e "\n"
}

SJF_N(){

	take_input
	sort_at
	sjf_n
	find_avgtime
	gant_chart
	echo -e "\n"
}

SJF_P(){

	take_input
	sort_at

	echo -e "\n\t\t\tGANTT CHART\t\t\n"
	echo -e "* represents 1 time unit each and # comes at intervals of 5 time units\n"

	sjf_p
	find_avgtime
}

Priority_Scheduling(){

	take_input 1
	sort_at 1
	priority_scheduling
	find_avgtime
	gant_chart
	echo -e "\n"

}

Round_Robin(){

	echo "Enter the time quantum: "
	read time_q
	take_input
	sort_at

	echo -e "\n\t\t\tGANTT CHART\t\t\n"
	echo "* represents 1 time unit each and # comes at intervals of 5 time units"


	round_robin
	find_avgtime
}

main(){

	while :
	do
		display_menu
		echo "Enter your choice: "
		read choice
		case $choice in
			1)	FCFS;;
			2) SJF_N;;
			3) SJF_P;;
			4) Priority_Scheduling;;
			5) Round_Robin;;
			6) exit 0 ;;
			*) echo "Please enter valid choice";;
		esac
	done
}

main