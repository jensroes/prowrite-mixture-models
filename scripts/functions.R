# Indicate deletion and insertion 
indicate_dels_and_inserts <- function(data){
  data %>%
    # remove typing/clicking outside word document
    filter(!(is.na(position) & !type %in% c("replacement", "insert")),
           type %in% c("insert", "keyboard", "replacement")) %>%
    select(task = folder, logguid, id, type, output, position, positionFull, doclengthFull, charProduction,
           pauseTime, pauseLocationFull, startTime, endTime) %>%
    group_by(task, logguid) %>%
    mutate(arrowkeys = output %in% c("RIGHT", "LEFT", "DOWN", "UP"), 
           leadingedge = (positionFull == doclengthFull), 
           # Deletion
           deletion = ifelse((
             # backspace key or doclength reduced
             output == "BACK" | lead(doclengthFull) < doclengthFull) |
               #selection + backspace
               (type == "replacement" & lead(output) == "BACK" & 
                  positionFull == lead(positionFull) & pauseTime != 0 &
                  # selection resulted in reduced doc length
                  lead(doclengthFull,2) < lead(doclengthFull)), 1, 0),
           # start new deletion if position is changed during deletion
           deletion = ifelse((type == "replacement" &
                                lag(output) == "BACK" & deletion == 1) | 
                               (((type == "replacement" & 
                                    lag(type) == "replacement") | 
                                   (output == "BACK" & 
                                      lag(output) == "BACK")) &
                                  abs(lag(positionFull) - positionFull) > 1),
                             lag(deletion) + 1, deletion),
           deletion = ifelse(is.na(deletion), 0, deletion),
           # Insertion
           insertion = ifelse(type == "insert" |
                                (((lag(arrowkeys) | !(positionFull - lag(positionFull)) 
                                   %in% c(0,1)) & !lag(deletion) &
                                    type == "keyboard" &
                                    !arrowkeys & !leadingedge & !deletion)), 1, 0), 
           insertion = ifelse(is.na(insertion), 0, insertion)) %>% 
    ungroup()
}

