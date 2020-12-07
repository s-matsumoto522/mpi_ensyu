program main
    implicit none
    include 'mpif.h'
    integer ierr
    integer procs
    integer myrank

    integer send_rank, recv_rank
    integer send1, send2, recv1, recv2
    integer req1s, req2s, req1r, req2r
    integer, dimension(MPI_STATUS_SIZE) :: sta1s, sta2s, sta1r, sta2r

    call MPI_Init(ierr)
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    !data for send
    send1 = myrank
    send2 = myrank**2
    recv1 = 100
    recv2 = 200

    send_rank = myrank + 1
    recv_rank = myrank - 1

    if(myrank == 0) then
        recv_rank = MPI_PROC_NULL
    else if(myrank == procs - 1) then
        send_rank = MPI_PROC_NULL
    endif

    !send data
    call MPI_Isend(send1, 1, MPI_INTEGER, send_rank, 1, MPI_COMM_WORLD, req1s, ierr)
    call MPI_Isend(send2, 1, MPI_INTEGER, send_rank, 2, MPI_COMM_WORLD, req2s, ierr)

    !recieve data
    call MPI_Irecv(recv1, 1, MPI_INTEGER, recv_rank, 1, MPI_COMM_WORLD, req1r, ierr)
    call MPI_Irecv(recv2, 1, MPI_INTEGER, recv_rank, 2, MPI_COMM_WORLD, req2r, ierr)

    !wait
    call MPI_Wait(req1s, sta1s, ierr)
    call MPI_Wait(req2s, sta2s, ierr)
    call MPI_Wait(req1r, sta1r, ierr)
    call MPI_Wait(req2r, sta2r, ierr)

    !output
    !if(myrank == 3) then
    !    write(*, *) 'recv1 :', recv1
    !    write(*, *) 'recv2 :', recv2
    !endif
    if(myrank == 3) then
        write(*, *) 'recv1 :', recv1
        write(*, *) 'recv2 :', recv2
    endif
    call MPI_Finalize(ierr)
end program main