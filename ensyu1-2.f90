program main
    implicit none
    include 'mpif.h'
    integer ierr        !MPI用エラーコード
    integer myrank      !自身のランク番号(0スタート)
    integer procs       !プロセス数(＝並列数)
    !character(2) chmyrank

    !---MPI並列開始---
    call MPI_Init(ierr)
    !---指定された並列数をprocsに格納---
    call MPI_Comm_Size(MPI_COMM_WORLD, procs, ierr)
    !----自分のランク番号をmyrankに格納---
    call MPI_Comm_Rank(MPI_COMM_WORLD, myrank, ierr)

    !write(chmyrank, '(i2.2)') myrank                    !myrankを文字型変数に格納
    !open(10, file = './output_'//chmyrank//'.d')        !ランク番号がついたファイルを作成
    write(*, *) 'Hello World'
    write(*, *) 'Myrank :', myrank
    !close(10)

    !---MPI並列の終了---
    call MPI_Finalize(ierr)
end program main