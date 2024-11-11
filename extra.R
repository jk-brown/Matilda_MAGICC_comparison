# EXTRA -------------------------------------------------------------------
#consider adding as a function to check the emissions that are present in GCAM data that are not in Hector map.

# Identify values in df1$ghg that are not in df2$ghg
unique_values_not_in_df2 <- test_df$ghg[!test_df$ghg %in% hector_emiss$ghg]

# Get unique values
unique_values_not_in_df2 <- unique(unique_values_not_in_df2)

# Print the result
unique_values_not_in_df2