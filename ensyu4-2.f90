program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank, output
    integer send_rank, recv_rank
    integer req_send, req_recv
    integer, dimension(MPI_STATUS_SIZE) :: sta_send, sta_recv
    character(2) :: chmyrank

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    write(chmyrank, '(i2.2)') myrank

    !assign the number of the relations
    if(myrank == 0) then
        send_rank = myrank + 1
        recv_rank = procs - 1
    else if(myrank == procs - 1) then
        send_rank = 0
        recv_rank = myrank - 1
    else
        send_rank = myrank + 1
        recv_rank = myrank - 1
    endif

    !send&recieve
    call MPI_Isend(myrank, 1, MPI_INTEGER, send_rank, 0, MPI_COMM_WORLD, req_send, ierr)
    call MPI_Irecv(output, 1, MPI_INTEGER, recv_rank, 0, MPI_COMM_WORLD, req_recv, ierr)

    call MPI_Wait(req_send, sta_send, ierr)
    call MPI_Wait(req_recv, sta_recv, ierr)

    open(10, file = 'output_'//chmyrank//'.d')
    write(10, *) 'myrank :', myrank
    write(10, *) 'output :', output
    close(10)

    call MPI_Finalize(ierr)
end program main