// ******************** JS cuộn menu ********************
(function () {
    const menu = document.getElementById('menuScroll');
    const leftBtn = document.getElementById('menuLeft');
    const rightBtn = document.getElementById('menuRight');

    function updateArrows() {
        // show arrows only if scrollable
        const scrollable = menu.scrollWidth > menu.clientWidth + 1;
        leftBtn.classList.toggle('d-none', !scrollable);
        rightBtn.classList.toggle('d-none', !scrollable);

        // hide left if at start
        leftBtn.style.visibility = (menu.scrollLeft > 5) ? 'visible' : 'hidden';
        // hide right if at end
        rightBtn.style.visibility = (menu.scrollLeft + menu.clientWidth < menu.scrollWidth - 5) ? 'visible' : 'hidden';
    }

    // scroll by amount
    function scrollByAmount(amount) {
        menu.scrollBy({ left: amount, behavior: 'smooth' });
    }

    leftBtn.addEventListener('click', () => scrollByAmount(-200));
    rightBtn.addEventListener('click', () => scrollByAmount(200));

    // update when resizing or content changes or scrolls
    window.addEventListener('resize', updateArrows);
    menu.addEventListener('scroll', updateArrows);

    // initial
    window.addEventListener('load', () => {
        // small delay to let layout compute
        setTimeout(updateArrows, 50);
});
})();

// ******************** JS tìm kiếm ******************** 
document.addEventListener('DOMContentLoaded', function() {
    const searchIconToggle = document.getElementById('searchIconToggle');
    const searchBarOverlay = document.getElementById('searchBarOverlay');
    const closeSearchBtn = document.getElementById('closeSearchBtn');

    // 1. Mở thanh tìm kiếm
    if (searchIconToggle) {
        searchIconToggle.addEventListener('click', function(e) {
            e.preventDefault();
            searchBarOverlay.classList.add('active');
            const searchInput = searchBarOverlay.querySelector('.search-input');
            if (searchInput) {
                setTimeout(() => searchInput.focus(), 300);
            }
        });
    }

    // Hàm đóng thanh tìm kiếm
    function closeSearchOverlay() {
        searchBarOverlay.classList.remove('active');
    }

    // 2. Đóng thanh tìm kiếm bằng nút X
    if (closeSearchBtn) {
        closeSearchBtn.addEventListener('click', closeSearchOverlay);
    }

    // 3. Tùy chọn: Đóng khi nhấn phím ESC
    document.addEventListener('keydown', function(e) {
        if (e.key === "Escape" && searchBarOverlay.classList.contains('active')) {
            closeSearchOverlay();
        }
    });

    // Đóng thanh tìm kiếm khi click bên ngoài nó
    document.addEventListener('click', function(e) {
        // Kiểm tra xem thanh tìm kiếm có đang mở không
        if (searchBarOverlay.classList.contains('active')) {
            // Kiểm tra xem vị trí click có NẰM NGOÀI thanh tìm kiếm và NẰM NGOÀI icon mở tìm kiếm hay không
            const isClickInsideSearchBar = searchBarOverlay.contains(e.target);
            const isClickOnToggleIcon = searchIconToggle.contains(e.target);

            if (!isClickInsideSearchBar && !isClickOnToggleIcon) {
                closeSearchOverlay();
            }
        }
    });
});

// ******************** JS cuộn section ******************** 
document.querySelectorAll('.categoryCarousel').forEach(carousel => {
    const wrapper = carousel.querySelector('.categoryWrapper');
const btnPrev = carousel.querySelector('.btnPrev');
const btnNext = carousel.querySelector('.btnNext');

// Chiều rộng cố định
const FIXED_CATEGORY_WIDTH = 200;
const FIXED_REVIEW_WIDTH_WITH_GAP = 605;

// Lấy loại carousel
const carouselType = carousel.dataset.type || 'category'; 
let currentIndex = 0;
const totalItems = wrapper.children.length;

// Các hàm
function shouldShowButtonsGlobally() {
    if (carouselType === 'review') {
        return totalItems > 3;
    }
    return totalItems > 7;
}
    
// Tính số item hiển thị dựa trên chiều rộng thực tế của container
function getVisibleItemsCount() {
    const width = carousel.clientWidth;
    const itemWidth = (carouselType === 'review') ? FIXED_REVIEW_WIDTH_WITH_GAP : FIXED_CATEGORY_WIDTH;

    return Math.floor(width / itemWidth);
}

function updateCarousel() {
    const itemWidth = (carouselType === 'review') ? FIXED_REVIEW_WIDTH_WITH_GAP : FIXED_CATEGORY_WIDTH;
        
    const visibleItems = getVisibleItemsCount();
    const maxIndex = totalItems - visibleItems;
    const isScrollable = totalItems > visibleItems;
        
    const showGlobally = shouldShowButtonsGlobally();
        
    const shouldShow = showGlobally || isScrollable;

    if (!shouldShow || !isScrollable) {
        btnPrev.style.display = "none";
        btnNext.style.display = "none";

        wrapper.style.transform = `translateX(0px)`; 
        return;
    }

    currentIndex = Math.min(currentIndex, Math.max(0, maxIndex));

    const translateX = -(currentIndex * itemWidth);
    wrapper.style.transform = `translateX(${translateX}px)`;

btnPrev.style.display = currentIndex > 0 ? "flex" : "none";
btnNext.style.display = currentIndex < maxIndex ? "flex" : "none";
}

// Xử lý sự kiện

btnNext.addEventListener('click', () => {
    const maxIndex = totalItems - getVisibleItemsCount(); 
if (currentIndex < maxIndex) {
    currentIndex++;
    updateCarousel();
}
});

btnPrev.addEventListener('click', () => {
    if (currentIndex > 0) {
        currentIndex--;
updateCarousel();
}
});

window.addEventListener('resize', () => {
    currentIndex = 0;
updateCarousel();
});

// Gọi khi load
updateCarousel();
});


// ******************** JS phân trang ******************** 
document.addEventListener('DOMContentLoaded', function () {
    const productsContainer = document.getElementById('product-list');
    const paginationControls = document.getElementById('pagination-controls');
    const products = productsContainer.querySelectorAll('.product');
    const itemsPerPage = 12;
    const totalItems = products.length;
    const totalPages = Math.ceil(totalItems / itemsPerPage);
    let currentPage = 1;

    // --- Hàm hiển thị sản phẩm của trang hiện tại ---
    function displayProducts(page) {
        // Tính toán chỉ số bắt đầu và kết thúc
        const start = (page - 1) * itemsPerPage;
        const end = start + itemsPerPage;

        // Ẩn tất cả sản phẩm
        products.forEach(product => {
            product.style.display = 'none';
    });

    // Hiện các sản phẩm của trang hiện tại
    for (let i = start; i < end && i < totalItems; i++) {
        products[i].style.display = 'block';
    }
    currentPage = page;
    updatePaginationControls();
}

// --- Hàm tạo và cập nhật các nút phân trang ---
function updatePaginationControls() {
    paginationControls.innerHTML = ''; // Xóa các nút cũ

    // 1. Nút PREV 
    const prevItem = document.createElement('li');
    prevItem.classList.add('page-item');
    if (currentPage === 1) {
        prevItem.classList.add('disabled'); // Ẩn nút Pre ở Trang 1
        prevItem.style.display = 'none';
    }
    prevItem.innerHTML = `<a class="page-link" href="#" aria-label="Previous"><span aria-hidden="true">«</span></a>`;
    prevItem.addEventListener('click', (e) => {
        e.preventDefault();
    if (currentPage > 1) {
        displayProducts(currentPage - 1);
    }
});
paginationControls.appendChild(prevItem);

// 2. Các nút số trang (1, 2, 3, ...)
for (let i = 1; i <= totalPages; i++) {
    const pageItem = document.createElement('li');
    pageItem.classList.add('page-item');
    if (i === currentPage) {
        pageItem.classList.add('active');
    }
    pageItem.innerHTML = `<a class="page-link" href="#">${i}</a>`;
    pageItem.addEventListener('click', (e) => {
        e.preventDefault();
    displayProducts(i);
});
paginationControls.appendChild(pageItem);
}

// 3. Nút NEXT 
        const nextItem = document.createElement('li');
nextItem.classList.add('page-item');
if (currentPage === totalPages) {
    nextItem.classList.add('disabled'); // Ẩn nút Next ở Trang cuối
    nextItem.style.display = 'none';
}
nextItem.innerHTML = `<a class="page-link" href="#" aria-label="Next"><span aria-hidden="true">»</span></a>`;
nextItem.addEventListener('click', (e) => {
    e.preventDefault();
if (currentPage < totalPages) {
    displayProducts(currentPage + 1);
}
});
paginationControls.appendChild(nextItem);
}

// --- Khởi tạo ---
displayProducts(1);
});

// ******************** JS profile ******************** 
function previewImage(input) {
    if (input.files && input.files[0]) {
        var reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('preview').src = e.target.result;
            document.getElementById('imagePreview').style.display = 'block';
        }
        reader.readAsDataURL(input.files[0]);
    }
}

// Validate mật khẩu xác nhận
document.getElementById('confirmPassword')?.addEventListener('input', function() {
    var newPassword = document.getElementById('newPassword').value;
    var confirmPassword = this.value;
    
    if (newPassword !== confirmPassword) {
        this.setCustomValidity('Mật khẩu xác nhận không khớp!');
    } else {
        this.setCustomValidity('');
    }
});

// ******************** JS thông báo ******************** 
//document.addEventListener('DOMContentLoaded', function () {
//    const toast = document.getElementById("toast-success");
//    if (toast) {
//        setTimeout(function () {
//            toast.style.transition = "0.5s";
//            toast.style.opacity = "0";
//            toast.style.transform = "translateY(-10px)";

//            setTimeout(function () {
//                toast.remove();
//            }, 500);
//        }, 3000);
//    }
//});
