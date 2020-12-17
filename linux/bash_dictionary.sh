declare -A ip_mapping
ip_mapping=(["N1"]="1.1.1.1" ["N2"]="2.2.2.2" ["N3"]="3.3.3.3")
echo "${ip_mapping[@]}" # Values
echo "${!ip_mapping[@]}" # Keys
for node_name in "${!ip_mapping[@]}"; do echo "$node_name - ${ip_mapping[$node_name]}"; done 
echo "${ip_mapping[N1]}" 